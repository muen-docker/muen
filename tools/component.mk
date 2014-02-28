include ../../Makeconf

all: $(COMPONENT)

tests: test_$(COMPONENT)
	@obj/tests/test_runner $(TEST_OPTS)

$(COMPONENT): $(COMPONENT_DEPS)
	@gprbuild $(BUILD_OPTS) -P$@

test_$(COMPONENT): $(TEST_DEPS)
	@gprbuild $(BUILD_OPTS) -P$@ -XBUILD=tests

build_cov: $(COV_DEPS)
	@gprbuild $(BUILD_OPTS) -Ptest_$(COMPONENT) -XBUILD=coverage

clean:
	@rm -rf bin obj $(ADDITIONAL_CLEAN)