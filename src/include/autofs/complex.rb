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

# File:	include/autofs/complex.ycp
# Package:	Configuration of autofs
# Summary:	Dialogs definitions
# Authors:	Peter Varkoly <varkoly@novell.com>
#
# $Id: complex.ycp 29363 2006-03-24 08:20:43Z mzugec $
module Yast
  module AutofsComplexInclude
    def initialize_autofs_complex(include_target)
      Yast.import "UI"

      textdomain "autofs"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "Confirm"
      Yast.import "Autofs"


      Yast.include include_target, "autofs/helps.rb"
    end

    # Return a modification status
    # @return true if data was modified
    def Modified
      Autofs.Modified
    end

    def ReallyAbort
      !Autofs.Modified || Popup.ReallyAbort(true)
    end

    def PollAbort
      UI.PollInput == :abort
    end

    # Read settings dialog
    # @return `abort if aborted and `next otherwise
    def ReadDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "read", ""))
      # Autofs::AbortFunction = PollAbort;
      return :abort if !Confirm.MustBeRoot
      ret = Autofs.Read
      ret ? :next : :abort
    end

    # Write settings dialog
    # @return `abort if aborted and `next otherwise
    def WriteDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))
      # Autofs::AbortFunction = PollAbort;
      ret = Autofs.Write
      ret ? :next : :abort
    end
  end
end
