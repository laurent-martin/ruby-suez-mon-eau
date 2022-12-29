
all: tests
tests:
	. ./local/vars.sh && ./bin/suez_mon_eau -u "$$user" -p "$$pass"
clean:
	rm -f Gemfile.lock
