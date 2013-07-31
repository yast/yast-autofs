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

# File:	include/autofs/dialogs.ycp
# Package:	Configuration of autofs
# Summary:	Dialogs definitions
# Authors:	Peter Varkoly <varkoly@novell.com>
#
# $Id: dialogs.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module AutofsDialogsInclude
    def initialize_autofs_dialogs(include_target)
      Yast.import "UI"

      textdomain "autofs"

      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "Autofs"

      Yast.include include_target, "autofs/helps.rb"
      Yast.include include_target, "autofs/complex.rb"
    end

    # @param [Array<Hash{String => String>}] entries   a list of the entries in a map
    # @return          a ui table list on items
    def TableItems(entries)
      entries = deep_copy(entries)
      #y2milestone("Entries %1", entries);
      return [] if entries == nil
      Builtins.maplist(entries) do |etnry|
        it = Item(
          Id(Ops.get_string(etnry, "key", "")),
          Ops.get_string(etnry, "key", ""),
          Ops.get_string(etnry, "options", ""),
          Ops.get_string(etnry, "location", "")
        )
        deep_copy(it)
      end
    end

    # Add map dialog
    # @return the name of the new map
    def AddMapDialog
      UI.OpenDialog(
        Opt(:decorated),
        HBox(
          HSpacing(1),
          VBox(
            VSpacing(0.2),
            HSpacing(30),
            # text entry label
            TextEntry(Id(:mapname), _("Name of the map"), ""),
            VSpacing(0.2),
            # ok pushbutton: confirm the dialog
            ButtonBox(
              PushButton(Id(:ok), Label.OKButton),
              PushButton(Id(:cancel), Label.CancelButton)
            ),
            VSpacing(0.2)
          ),
          HSpacing(1)
        )
      )

      ret = nil
      mapname = ""
      while true
        ret = UI.UserInput
        # abort?
        if ret == :abort || ret == :cancel
          if ReallyAbort()
            break
          else
            next
          end
        elsif ret == :ok
          mapname = Convert.to_string(UI.QueryWidget(Id(:mapname), :Value))
          break
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end
      UI.CloseDialog
      if ret == :ok
        return mapname
      else
        return nil
      end
    end

    # Add/Modify entry dialog
    # @return the key the options and the location of the entry
    def EntryDialog(_Entry)
      _Entry = deep_copy(_Entry)
      _NewEntry = {}

      if _Entry == {}
        UI.OpenDialog(
          Opt(:decorated),
          HBox(
            MinWidth(
              25,
              ReplacePoint(
                Id(:Help),
                RichText(
                  Id(:HelpText),
                  Ops.get_string(@HELPS, "EntryDialogNFS", "")
                )
              )
            ),
            HSpacing(1),
            VBox(
              VSpacing(0.2),
              HSpacing(30),
              Frame(
                _("Type"),
                RadioButtonGroup(
                  Id(:type),
                  Opt(:notify),
                  HBox(
                    RadioButton(Id(:nfs), Opt(:notify), "NFS", true),
                    RadioButton(Id(:samba), Opt(:notify), "SAMBA", false),
                    RadioButton(Id(:other), Opt(:notify), _("Other"), false)
                  )
                )
              ),
              TextEntry(Id(:key), _("Key"), ""),
              ReplacePoint(
                Id(:fields),
                VBox(
                  TextEntry(
                    Id(:options),
                    _("Options"),
                    "-fstype=nfs,rw,soft,async"
                  ),
                  TextEntry(Id(:location1), _("Server"), ""),
                  TextEntry(Id(:location2), _("Path"), "")
                )
              ),
              VSpacing(0.2),
              # ok pushbutton: confirm the dialog
              ButtonBox(
                PushButton(Id(:ok), Label.OKButton),
                PushButton(Id(:cancel), Label.CancelButton)
              ),
              VSpacing(0.2)
            ),
            HSpacing(1)
          )
        )
      else
        UI.OpenDialog(
          Opt(:decorated),
          HBox(
            HSpacing(1),
            VBox(
              VSpacing(0.2),
              HSpacing(30),
              TextEntry(Id(:key), _("Key"), Ops.get(_Entry, "key", "")),
              TextEntry(
                Id(:options),
                _("Options"),
                Ops.get(_Entry, "options", "")
              ),
              TextEntry(
                Id(:location),
                _("Location"),
                Ops.get(_Entry, "location", "")
              ),
              VSpacing(0.2),
              # ok pushbutton: confirm the dialog
              ButtonBox(
                PushButton(Id(:ok), Label.OKButton),
                PushButton(Id(:cancel), Label.CancelButton)
              ),
              VSpacing(0.2)
            ),
            HSpacing(1)
          )
        )
      end
      ret = nil
      mapname = ""
      while true
        ret = UI.UserInput
        # abort?
        if ret == :abort || ret == :cancel
          if ReallyAbort()
            break
          else
            next
          end
        elsif ret == :nfs
          UI.ReplaceWidget(
            Id(:fields),
            VBox(
              TextEntry(Id(:options), _("Options"), "-fstype=nfs,rw,soft,async"),
              TextEntry(Id(:location1), _("Server"), ""),
              TextEntry(Id(:location2), _("Path"), "")
            )
          )
          UI.ReplaceWidget(
            Id(:Help),
            RichText(
              Id(:HelpText),
              Ops.get_string(@HELPS, "EntryDialogNFS", "")
            )
          )
          next
        elsif ret == :samba
          UI.ReplaceWidget(
            Id(:fields),
            VBox(
              TextEntry(Id(:options), _("Options"), "-fstype=cifs"),
              TextEntry(Id(:location1), _("Server"), ""),
              TextEntry(Id(:location2), _("Share"), "")
            )
          )
          UI.ReplaceWidget(
            Id(:Help),
            RichText(
              Id(:HelpText),
              Ops.get_string(@HELPS, "EntryDialogSAMBA", "")
            )
          )
          next
        elsif ret == :other
          UI.ReplaceWidget(
            Id(:fields),
            VBox(
              TextEntry(Id(:options), _("Options"), ""),
              TextEntry(Id(:location), _("Location"), "")
            )
          )
          UI.ReplaceWidget(
            Id(:Help),
            RichText(
              Id(:HelpText),
              Ops.get_string(@HELPS, "EntryDialogOther", "")
            )
          )
          next
        elsif ret == :ok
          Ops.set(
            _NewEntry,
            "key",
            Convert.to_string(UI.QueryWidget(Id(:key), :Value))
          )
          Ops.set(
            _NewEntry,
            "options",
            Convert.to_string(UI.QueryWidget(Id(:options), :Value))
          )
          if UI.WidgetExists(Id(:location1))
            if UI.QueryWidget(Id(:type), :CurrentButton) == :samba
              Ops.set(
                _NewEntry,
                "location",
                Ops.add(
                  Ops.add(
                    "://",
                    Convert.to_string(UI.QueryWidget(Id(:location1), :Value))
                  ),
                  Convert.to_string(UI.QueryWidget(Id(:location2), :Value))
                )
              )
            else
              Ops.set(
                _NewEntry,
                "location",
                Ops.add(
                  Ops.add(
                    Convert.to_string(UI.QueryWidget(Id(:location1), :Value)),
                    ":"
                  ),
                  Convert.to_string(UI.QueryWidget(Id(:location2), :Value))
                )
              )
            end
          else
            Ops.set(
              _NewEntry,
              "location",
              Convert.to_string(UI.QueryWidget(Id(:location), :Value))
            )
          end
          break
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end
      UI.CloseDialog
      if ret == :ok
        return deep_copy(_NewEntry)
      else
        return nil
      end
    end

    # Autofs configurations dialog, for add delete or modify maps and map entries
    # @return dialog result
    def ConfigureDialog
      # Autofs configure1 dialog caption
      caption = _("Autofs Configuration")

      _LMaps = Autofs.GetLMaps

      # Autofs configure1 dialog contents
      contents = VBox(
        ReplacePoint(
          Id(:mapslist),
          SelectionBox(Id(:maps), Opt(:notify), _("Maps"), _LMaps)
        ),
        ButtonBox(
          PushButton(Id(:addmap), _("Add")),
          PushButton(Id(:delmap), _("Delete"))
        ),
        Table(Id(:entries), Header(_("Key"), _("Options"), _("Location")), []),
        ButtonBox(
          PushButton(Id(:addentry), _("Add")),
          #                `PushButton(`id(`modentry), _("Edit")),
          PushButton(Id(:delentry), _("Delete"))
        )
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "ConfigureDialog", ""),
        Label.BackButton,
        Label.NextButton
      )

      Wizard.SetNextButton(:next, Label.FinishButton)
      UI.ChangeWidget(Id(:back), :Enabled, false)

      actmap = ""
      # preselect an item - convenience, button enabling
      if Ops.greater_than(Builtins.size(_LMaps), 0)
        UI.ChangeWidget(Id(:maps), :CurrentItem, Ops.get(_LMaps, 0, ""))
        actmap = Convert.to_string(UI.QueryWidget(Id(:maps), :CurrentItem))
        UI.ChangeWidget(
          Id(:entries),
          :Items,
          TableItems(Autofs.GetEntriesOfMap(actmap))
        )
      end

      ret = nil
      while true
        ret = UI.UserInput
        # abort?
        if ret == :abort || ret == :cancel
          if ReallyAbort()
            break
          else
            next
          end
        # click on a map
        elsif ret == :maps
          actmap = Convert.to_string(UI.QueryWidget(Id(:maps), :CurrentItem))
          UI.ChangeWidget(
            Id(:entries),
            :Items,
            TableItems(Autofs.GetEntriesOfMap(actmap))
          )
          next
        # addmap
        elsif ret == :addmap
          newmap = AddMapDialog()
          if newmap != nil
            Autofs.AddMap(newmap)
            _LMaps = Autofs.GetLMaps
            UI.ReplaceWidget(
              Id(:mapslist),
              SelectionBox(Id(:maps), Opt(:notify), _("Maps"), _LMaps)
            )
            UI.ChangeWidget(Id(:maps), :CurrentItem, newmap)
            actmap = newmap
          end
          next
        # remove a map
        elsif ret == :delmap
          Autofs.DelMap(actmap)
          _LMaps = Autofs.GetLMaps
          UI.ReplaceWidget(
            Id(:mapslist),
            SelectionBox(Id(:maps), Opt(:notify), _("Maps"), _LMaps)
          )
          if Ops.greater_than(Builtins.size(_LMaps), 0)
            UI.ChangeWidget(Id(:maps), :CurrentItem, Ops.get(_LMaps, 0, ""))
            actmap = Convert.to_string(UI.QueryWidget(Id(:maps), :CurrentItem))
          end
          next
        # add a new entry
        elsif ret == :addentry
          _NewEntry = EntryDialog({})
          if _NewEntry != nil
            Autofs.AddEntry(actmap, _NewEntry)
            UI.ChangeWidget(
              Id(:entries),
              :Items,
              TableItems(Autofs.GetEntriesOfMap(actmap))
            )
          end
          next
        # delete an entry
        elsif ret == :delentry
          key = Convert.to_string(UI.QueryWidget(Id(:entries), :CurrentItem))
          if key != nil
            Autofs.DelEntry(key, actmap)
            UI.ChangeWidget(
              Id(:entries),
              :Items,
              TableItems(Autofs.GetEntriesOfMap(actmap))
            )
          end
          next
        elsif ret == :next || ret == :back
          break
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end

      deep_copy(ret)
    end
  end
end
