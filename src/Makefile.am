# Makefile.am for autofs/src

yncludedir = @yncludedir@/autofs

client_DATA =			\
	autofs.ycp		

ynclude_DATA =			\
	helps.ycp		\
	wizards.ycp		\
	dialogs.ycp		\
	complex.ycp

desktop_DATA =			\
	autofs.desktop

module_DATA =			\
	Autofs.pm		\
	AutofsUI.ycp

# create a symlink for local build, #145327
autofs:
	ln -sf . $@
ycpchook = autofs

EXTRA_DIST = $(client_DATA) $(ynclude_DATA) $(module_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
