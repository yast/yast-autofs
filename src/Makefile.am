# Sources for autofs

module_DATA = \
  modules/AutofsUI.rb \
  modules/Autofs.pm

client_DATA = \
  clients/autofs.rb

yncludedir = @yncludedir@/autofs
ynclude_DATA = \
  include/autofs/wizards.rb \
  include/autofs/dialogs.rb \
  include/autofs/complex.rb \
  include/autofs/helps.rb

desktop_DATA = \
  desktop/autofs.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common