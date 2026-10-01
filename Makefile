.PHONY: install uninstall reinstall

PREFIX ?= /usr/local
# Termux has no system /etc or /usr/local: everything lives under $PREFIX,
# so default all install locations below $PREFIX when it looks like Termux.
ifneq (,$(findstring com.termux,$(PREFIX)))
SYSCONFDIR ?= $(PREFIX)/etc
BASHCOMPDIR ?= $(PREFIX)/etc/bash_completion.d
ZSHCOMPDIR ?= $(PREFIX)/share/zsh/functions/Completion/Debian
# Termux has no sbin directory and only $PREFIX/bin is on PATH.
SBINDIR ?= $(PREFIX)/bin
else
SYSCONFDIR ?= /etc
BASHCOMPDIR ?= /etc/bash_completion.d
ZSHCOMPDIR ?= /usr/share/zsh/functions/Completion/Debian
SBINDIR ?= $(PREFIX)/sbin
endif
MANDIR ?= $(PREFIX)/share/man

install: apt-fast completions/bash/apt-fast
	apt-get install -y -qq aria2
	mkdir -p $(DESTDIR)$(SBINDIR)
	cp apt-fast $(DESTDIR)$(SBINDIR)/
	mkdir -p $(DESTDIR)$(SYSCONFDIR)
	[ -f $(DESTDIR)$(SYSCONFDIR)/apt-fast.conf ] || cp apt-fast.conf $(DESTDIR)$(SYSCONFDIR)/
	mkdir -p $(DESTDIR)$(BASHCOMPDIR)
	mkdir -p $(DESTDIR)$(ZSHCOMPDIR)
	cp completions/bash/apt-fast $(DESTDIR)$(BASHCOMPDIR)/
	cp completions/zsh/_apt-fast $(DESTDIR)$(ZSHCOMPDIR)/
# chown only makes sense as root (Termux installs as a regular user).
	if [ "$$(id -u)" -eq 0 ]; then \
	  chown root:root $(DESTDIR)$(BASHCOMPDIR)/apt-fast; \
	  chown root:root $(DESTDIR)$(ZSHCOMPDIR)/_apt-fast; \
	fi
	mkdir -p $(DESTDIR)$(MANDIR)/man8/
	mkdir -p $(DESTDIR)$(MANDIR)/man5/
	cp man/apt-fast.8 $(DESTDIR)$(MANDIR)/man8/
	cp man/apt-fast.conf.5 $(DESTDIR)$(MANDIR)/man5/
	gzip -f9 $(DESTDIR)$(MANDIR)/man8/apt-fast.8
	gzip -f9 $(DESTDIR)$(MANDIR)/man5/apt-fast.conf.5
	chmod +x $(DESTDIR)$(SBINDIR)/apt-fast

uninstall: $(DESTDIR)$(SBINDIR)/apt-fast
	rm -rf $(DESTDIR)$(SBINDIR)/apt-fast $(DESTDIR)$(SYSCONFDIR)/apt-fast.conf \
	$(DESTDIR)$(MANDIR)/man5/apt-fast.conf.5.gz $(DESTDIR)$(MANDIR)/man8/apt-fast.8.gz \
	$(DESTDIR)$(ZSHCOMPDIR)/_apt-fast $(DESTDIR)$(BASHCOMPDIR)/apt-fast
	@echo "Please manually remove deb package - aria2 if you don't need it anymore."

$(DESTDIR)$(SBINDIR)/apt-fast:
	@echo "Not installed" 1>&2
	@exit 1

reinstall: uninstall install
