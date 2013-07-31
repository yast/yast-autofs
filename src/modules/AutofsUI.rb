# encoding: utf-8

# File:        modules/AutofsUI.ycp
# Package:     Configuration of autofs
# Summary:     UI-related routines to be run from perl modules (Autofs.pm etc.)
# Author:      Peter Varkoly <varkoly@novell.com>
#
# $Id: AutofsUI.ycp 26218 2005-11-21 15:15:22Z jsuchome $
require "yast"

module Yast
  class AutofsUIClass < Module
    def main
      Yast.import "UI"
      textdomain "autofs"
      Yast.import "Label"
      Yast.import "Popup"

      Yast.include self, "autofs/helps.rb"
    end

    def GetLDAPServer(hostname)
      UI.OpenDialog(
        Opt(:decorated),
        HBox(
          HSpacing(1),
          VBox(
            VSpacing(0.2),
            HSpacing(30),
            RichText(Id(:HelpText), Ops.get_string(@HELPS, "GetLDAPServer", "")),
            # text entry label
            TextEntry(
              Id(:ldapserver),
              _("DNS Name or IP address of the LDAP server"),
              hostname
            ),
            VSpacing(0.2),
            # ok pushbutton: confirm the dialog
            HBox(
              PushButton(Id(:ok), Label.OKButton),
              PushButton(Id(:cancel), Label.CancelButton)
            ),
            VSpacing(0.2)
          ),
          HSpacing(1)
        )
      )

      ret = nil
      ldapserver = "no"
      while true
        ret = UI.UserInput
        # abort?
        if ret == :abort || ret == :cancel
          if Popup.ReallyAbort(false)
            break
          else
            next
          end
        elsif ret == :ok
          ldapserver = Convert.to_string(
            UI.QueryWidget(Id(:ldapserver), :Value)
          )
          break
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end
      UI.CloseDialog
      ldapserver
    end

    publish :function => :GetLDAPServer, :type => "string (string)"
  end

  AutofsUI = AutofsUIClass.new
  AutofsUI.main
end
