#
# spec file for package yast2-autofs
#
# Copyright (c) 2013 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-autofs
Version:        3.0.1
Release:        0

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2


Group:          System/YaST
License:        GPL-2.0
# Wizard::SetDesktopTitleAndIcon
Requires:	yast2 >= 2.21.22
BuildRequires:	update-desktop-files yast2
BuildRequires:  yast2-devtools >= 3.0.6

BuildArchitectures:	noarch

Requires:       yast2-ruby-bindings >= 1.0.0

Summary:	YaST2 - Module to Create and Manage autofs Entries in LDAP

%description
This makes possible to create and manage autofs entries in an LDAP
server. The autofs entries will be created according the nis.schema
using the objectclasses nisMap and nisObject. The entries are placed
under ou=AUTOFS,$LDAPBASE.

%prep
%setup -n %{name}-%{version}

%build
%yast_build

%install
%yast_install


%files
%defattr(-,root,root)
%dir %{yast_yncludedir}/autofs
%{yast_yncludedir}/autofs/*
%{yast_clientdir}/autofs.rb
%{yast_moduledir}/Autofs*
%{yast_desktopdir}/autofs.desktop
%doc %{yast_docdir}
