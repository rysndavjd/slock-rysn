# slock - simple screen locker
# See LICENSE file for copyright and license details.

include config.mk

SRC = slock.c ${COMPATSRC}
OBJ = ${SRC:.c=.o}

all: options slock

options:
	@echo slock-rysn build options:
	@echo "CFLAGS   = ${CFLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@echo "CC       = ${CC}"

.c.o:
	@echo CC $<
	@${CC} -c ${CFLAGS} $<

${OBJ}: config.h config.mk arg.h util.h

config.h:
	@echo creating $@ from config.def.h
	@cp config.def.h $@

slock: ${OBJ}
	@echo CC -o $@
	@${CC} -o $@ ${OBJ} ${LDFLAGS}

clean:
	@echo cleaning
	@rm -f slock ${OBJ} slock-rysn-${VERSION}.tar.gz

dist: clean
	@echo creating dist tarball
	@mkdir -p slock-rysn-${VERSION}
	@cp -R LICENSE Makefile README slock.1 config.mk \
		${SRC} config.def.h arg.h util.h \
		addons patchs config.h slock-rysn-${VERSION}
	@tar -cf slock-rysn-${VERSION}.tar slock-rysn-${VERSION}
	@gzip slock-rysn-${VERSION}.tar
	@rm -rf slock-rysn-${VERSION}

install: all
	@echo installing executable file to ${DESTDIR}${PREFIX}/bin
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@cp -f slock ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/slock
	@chmod u+s ${DESTDIR}${PREFIX}/bin/slock
	@echo installing manual page to ${DESTDIR}${MANPREFIX}/man1
	@mkdir -p ${DESTDIR}${MANPREFIX}/man1
	@sed "s/VERSION/${VERSION}/g" <slock.1 >${DESTDIR}${MANPREFIX}/man1/slock.1
	@chmod 644 ${DESTDIR}${MANPREFIX}/man1/slock.1
	@mkdir ${DESTDIR}/etc/polkit-1/rules.d
	@cp -f addons/polkit/50-poweroff.rules ${DESTDIR}/etc/polkit-1/rules.d/50-poweroff.rules
	@chmod 700 ${DESTDIR}/etc/polkit-1/rules.d/50-poweroff.rules
	@chown polkitd: ${DESTDIR}/etc/polkit-1/rules.d/50-poweroff.rules

uninstall:
	@echo removing executable file from ${DESTDIR}${PREFIX}/bin
	@rm -f ${DESTDIR}${PREFIX}/bin/slock
	@echo removing manual page from ${DESTDIR}${MANPREFIX}/man1
	@rm -f ${DESTDIR}${MANPREFIX}/man1/slock.1

.PHONY: all options clean dist install uninstall
