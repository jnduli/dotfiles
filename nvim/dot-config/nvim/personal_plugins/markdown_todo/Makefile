# Variable for the test runner command to keep things clean
TEST_COMMAND = nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.lua'}"

.PHONY: test

# The default 'make' command will run tests
test:
	@echo "Running Unit Tests..."
	$(TEST_COMMAND)
