# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File:	include/autofs/helps.ycp
# Package:	Configuration of autofs
# Summary:	Help texts of all the dialogs
# Authors:	Peter Varkoly <varkoly@novell.com>
#
# $Id: helps.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module AutofsHelpsInclude
    def initialize_autofs_helps(include_target)
      textdomain "autofs"

      # All helps are here
      @HELPS = {
        # Read dialog help 1/2
        "read"             => _(
          "<p><b>Initializing autofs configuration</b><br>\n</p>\n"
        ) +
          # Read dialog help 2/2
          _(
            "<p><b><big>Aborting Initialization:</big></b><br>\nSafely abort the configuration utility by pressing <b>Abort</b> now.</p>\n"
          ),
        # Write dialog help 1/2
        "write"            => _(
          "<p><b>Saving autofs configuration</b><br>\n</p>\n"
        ) +
          # Write dialog help 2/2
          _(
            "<p><b>Aborting Save:</b><br>\n" +
              "Abort the save procedure by pressing <b>Abort</b>.\n" +
              "</p>\n"
          ),
        # Configure dialog help 1/4
        "ConfigureDialog"  => _(
          "<p><b>Automounter Maps</b><br/>\n" +
            "The automounter maps are referred to by the master map of the\n" +
            "automounter. Entries in the automounter maps describe how file\n" +
            "systems below the mount point of the map are to be mounted.\n" +
            "<br/></p>\n"
        ) +
          # Configure dialog help 2/4
          _(
            "<p><b><big>Key</big></b><br>\n" +
              "This is the part of the pathname between the map mount point and\n" +
              "the path into the filesystem mounted.\n" +
              "</p>"
          ) +
          # Configure dialog help 3/4
          _(
            "<p><b><big>Options</big></b><br>\n" +
              "The options are comma separated, as customary for the <b>mount</b>(8) command.\n" +
              "<br></p>\n"
          ) +
          # Configure dialog help 4/4
          _(
            "<p><b><big>Location</big></b><br>\n" +
              "The location specifies from where the file system is to be mounted.\n" +
              "For an NFS volume the usual notation is host:pathname.\n" +
              "If the filesystem to be mounted begins with a '/' (such as local\n" +
              "entries or smbfs shares) a ':' needs to be prefixed.\n" +
              "</p>"
          ),
        # EntryDialog for NFS entry
        "EntryDialogNFS"   => _(
          "<p><b><big>NFS Entry</big></b><br>\n" +
            "In the case of NFS entries, the <b>Server</b> is the DNS name or IP address of the NFS server.<br/>\n" +
            "The <b>Path</b> is the absolute path to the directory on the NFS server.<br/>\n" +
            "The <b>Options</b> must be valid options of the <b>mount</b>(8) command for NFS file systems.<br/>\n" +
            "<br/></p>\n"
        ),
        # EntryDialog for SAMBA entry
        "EntryDialogSAMBA" => _(
          "<p><b>SAMBA Entry</b><br/>\n" +
            "In the case of SAMBA entries, the <b>Server</b> is the DNS name or IP address of the SAMBA server.<br/>\n" +
            "The <b>Share</b> is the name of the SAMBA share to be mounted.<br/>\n" +
            "The <b>Options</b> must be valid options of the <b>mount</b>(8) command for SMB/CIFS file systems.<br>\n" +
            "<br/></p>\n"
        ),
        # EntryDialog for Other entry
        "EntryDialogOther" => _(
          "<p><b><big>Other Entry</big></b><br/>\n" +
            "The options are comma-separated, which is customary for the <b>mount</b>(8) command.<br/>\n" +
            "The location specifies from where the file system is to be mounted.\n" +
            "Consult the <b>autofs</b>(5) manual page for more information.\n" +
            "<br/></p>\n"
        ),
        # GetLDAPServer dialog if the ldapserver is localhost
        "GetLDAPServer"    => _(
          "<p><b><big>Warning</big></b><br> In your system <b>localhost</b> is configured\n" +
            "as the LDAP server. Since clients cannot reach <b>localhost</b>, it\n" +
            "cannot act as LDAP server for autofs.  Specify an IP address or DNS name of a\n" +
            "suitable LDAP server or choose the suggested hostname of your server and press\n" +
            "<b>Ok</b>.  <br></p>\n"
        )
      } 

      # EOF
    end
  end
end
