# Make sure to set ROKU_PWD and ROKU_IP !
# (in .env or Make CLI arguments)
-include .env
PKG_NAME=Twoku
PKG_OUT=$(PKG_NAME).zip
AR=zip
_GIT_IGNORED=$(shell grep -v '^#\|^$$' .gitignore | tr '\n' ' ')
AR_EXC=Makefile README.md ".git/*" .gitignore $(_GIT_IGNORED)
AR_COMPLVL=6
AR_ARGS=-$(AR_COMPLVL) -r $(PKG_OUT) . -x $(AR_EXC)

.PHONY: all .precheck package upload clean

all: .precheck package upload

.precheck: .precheck_upload

.precheck_upload:
	@if [ -z "$(ROKU_IP)" ]; then\
		echo "ROKU_IP not set, can't connect to device!";\
		exit 1;\
	fi
	@if [ -z "$(ROKU_PWD)" ]; then\
		echo "ROKU_PWD not set, can't authenticate with $(ROKU_IP)!";\
		exit 1;\
	fi

# Alias
pkg: package

package:
	$(AR) $(AR_ARGS)

upload: .precheck_upload
	curl --digest -u "rokudev:$(ROKU_PWD)" -F "mysubmit=Install" -F "archive=@$(PKG_OUT)" http://$(ROKU_IP)/plugin_install

clean:
	rm *.zip
