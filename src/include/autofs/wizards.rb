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

# File:	include/autofs/wizards.ycp
# Package:	Configuration of autofs
# Summary:	Wizards definitions
# Authors:	Peter Varkoly <varkoly@novell.com>
#
# $Id: wizards.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module AutofsWizardsInclude
    def initialize_autofs_wizards(include_target)
      Yast.import "UI"

      textdomain "autofs"

      Yast.import "Sequencer"
      Yast.import "Wizard"

      Yast.include include_target, "autofs/complex.rb"
      Yast.include include_target, "autofs/dialogs.rb"
    end

    # Whole configuration of autofs
    # @return sequence result
    def AutofsSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { ConfigureDialog() },
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Builtins.y2milestone("------Starting AutofsSequence ------")

      Wizard.CreateDialog
      Wizard.SetDesktopTitleAndIcon("autofs")

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end

    # Whole configuration of autofs but without reading and writing.
    # For use with autoinstallation.
    # @return sequence result
    def AutofsAutoSequence
      # Initialization dialog caption
      caption = _("Autofs Configuration")
      # Initialization dialog contents
      contents = Label(_("Initializing..."))

      # Wizard::CreateDialog();
      #     Wizard::SetContentsButtons(caption, contents, "",
      # 	    Label::BackButton(), Label::NextButton());
      #
      #     any ret = ConfigureDialog();
      #     UI::CloseDialog();
      #     return ret;
      nil
    end
  end
end
