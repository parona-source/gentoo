# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake edo

DESCRIPTION="Redis client written in C++"
HOMEPAGE="https://github.com/sewenew/redis-plus-plus"
SRC_URI="
	https://github.com/sewenew/redis-plus-plus/archive/refs/tags/${PV}.tar.gz
		-> ${P}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

IUSE="ssl test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/hiredis:=[ssl?]
	ssl? ( dev-libs/openssl )
"
RDEPEND="${DEPEND}"
BDEPEND="test? ( >=dev-db/redis-5[ssl?] )"

src_configure() {
	local mycmakeargs=(
		-DREDIS_PLUS_PLUS_USE_TLS=$(usex ssl) # todo
		-DREDIS_PLUS_PLUS_BUILD_STATIC=OFF
		-DREDIS_PLUS_PLUS_BUILD_SHARED=ON
		-DREDIS_PLUS_PLUS_BUILD_TEST=$(usex test)
		-DREDIS_PLUS_PLUS_BUILD_ASYNC_TEST=OFF # broken upstream
	)
	cmake_src_configure
}

src_test() {
	# https://github.com/sewenew/redis-plus-plus#run-tests-optional

	local host="127.0.0.1"
	local port="6379"
	local cluster_ports=( 700{0..2} )

	einfo "Start Redis test clusters ..."
	for cport in ${cluster_ports[@]} ; do
		redis-server --port ${cport} --cluster-enabled yes \
			--cluster-config-file "${T}"/nodes-${cport}.conf \
			--logfile "${T}"/redis-server-${cport}.log \
			--pidfile "${T}/redis-server-${cport}.pid" --daemonize yes
	done
	for cport in ${cluster_ports[@]} ; do
		local cluster_started=0
		for i in {1..10}; do
			if grep -q "Ready to accept connections tcp" "${T}"/redis-server-${cport}.log 2>/dev/null ; then
				cluster_started=1
				break
			else
				sleep 1
				continue
			fi
		done
		[[ ${cluster_started} -eq 0 ]] && die "Redis cluster ${cport} failed to start. See ${T}/redis-server-${cport}.log"
	done

	einfo "Configuring Redis test instance ..."
	edo redis-cli  --cluster-yes --cluster create ${cluster_ports[@]/#/${host}:}

	einfo "Start Redis test instance ..."
	redis-server --pidfile "${T}/redis-server.pid" --daemonize yes \
		--logfile "${T}"/redis-server.log --dir "${T}" --dbfilename redisdb.rdb
	local redis_started=0
	for i in {1..20}; do
		if grep -q "Ready to accept connections tcp" "${T}"/redis-server.log 2>/dev/null ; then
			redis_started=1
			break
		else
			sleep 1
			continue
		fi
	done
	[[ ${redis_started} -eq 0 ]] && die "Redis instance failed to start. See ${T}/redis-server.log"

	# Test Redis, Redis Cluster and multi-threads
	einfo "Running tests ..."
	nonfatal edo "${BUILD_DIR}"/test/test_redis++ -h ${host} -p ${port} -n ${host} -c ${cluster_ports[0]} -m
	local ret=${?}

	einfo "Stopping Redis test instance ..."
	# https://redis.io/docs/latest/operate/oss_and_stack/reference/signals/
	pkill -F "${T}/redis-server.pid" || die
	local redis_stopped=0
	for i in {1..20}; do
		if grep -q "Redis is now ready to exit, bye bye..." "${T}"/redis-server.log 2>/dev/null ; then
			redis_stopped=1
			break
		else
			sleep 1
			continue
		fi
	done
	[[ ${redis_stopped} -eq 0 ]] && eerror "Redis instance failed to stop. See ${T}/redis-server.log"

	einfo "Stopping Redis test clusters ..."
	for cport in ${cluster_ports[@]} ; do
		pkill -F "${T}/redis-server-${cport}.pid" || die
	done
	for cport in ${cluster_ports[@]} ; do
		local cluster_stopped=0
		for i in {1..10}; do
			if grep -q "Redis is now ready to exit, bye bye..." "${T}"/redis-server-${cport}.log 2>/dev/null ; then
				cluster_stopped=1
				break
			else
				sleep 1
				continue
			fi
		done
		[[ ${cluster_started} -eq 0 ]] && error "Redis cluster ${cport} failed to stop. See ${T}/redis-server-${cport}.log"
	done

	[[ ${ret} -ne 0 ]] && die "Tests failed"
}
