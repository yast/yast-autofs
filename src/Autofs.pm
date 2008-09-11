#! /usr/bin/perl -w

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

# File:		modules/Autofs.pm
# Package:	Configuration of autofs
# Summary:	Autofs settings, input and output functions
# Authors:	Peter Varkoly <varkoly@novell.com>
#
# $Id: Autofs2.pm 27914 2006-02-13 14:32:08Z locilka $
#
# Representation of the configuration of autofs.
# Input and output routines.


package Autofs;

BEGIN {
    push @INC, '/usr/share/YaST2/modules/';
}

use strict;

use YaST::YCP qw(Boolean :LOGGING);
use YaPI;

###
# Debug only;
# use Data::Dumper;

textdomain("autofs");

our %TYPEINFO;
our $VERSION="1.0.0";

YaST::YCP::Import ("Progress");
YaST::YCP::Import ("Popup");
YaST::YCP::Import ("Summary");
YaST::YCP::Import ("Message");
YaST::YCP::Import ("Ldap");
YaST::YCP::Import ("SCR");
YaST::YCP::Import ("AutofsUI");

##
 # Data was modified?
 #
my $modified = 0;

##
 #
my $proposal_valid = 0;

##
 # Write only, used during autoinstallation.
 # Don't run services and SuSEconfig, it's all done at one place.
 #
my $write_only = 0;

#
# Global Variables

##
 # The yast2 LDAP-Client configurations map
 #
my $ldapMap = undef;

##
 # The baseDN of the autofs configuration
 #
my $AUTOFSBase = undef;

##
 # The DN of the autofs maste map
 #
my $AutoMasterBase = undef;

##
 # The autofs maps
 #
my $Maps = {};

# Export
BEGIN{$TYPEINFO{GetLMaps}=["function", ["list", "string"]];}
sub GetLMaps {
	my ($self) = @_;
	my $LMaps  = [];
	y2milestone("------GetLMaps------");
	
	foreach my $k ( keys %{$Maps} )
	{
	  if( ! $Maps->{$k}->{deleted}  )
	  {
	      push @{$LMaps}, $k;
	  }
	}
	return $LMaps;
}

# Export
BEGIN{$TYPEINFO{GetMaps}=["function", ["map", "string","any"]];}
sub GetMaps {
	my ($self) = @_;
	y2milestone("------GetMaps------");
	return  $Maps;
}

##
 # Add a new map to the internal lists
 # 
BEGIN{$TYPEINFO{AddMap}=["function", "boolean", "string"];}
sub AddMap {
	my $self = shift;
	my $name = shift;
	y2milestone("------AddMap------");
	$Maps->{$name}->{'dn'}      = "";
	$Maps->{$name}->{'entries'} = [];
}

##
 # Delete a map from the internal lists
 # 
BEGIN{$TYPEINFO{DelMap}=["function", "boolean", "string"];}
sub DelMap {
	my $self = shift;
	my $name = shift;
	y2milestone("------DelMap------$name");
        $Maps->{$name}->{deleted} = 1;
}

##
 # Add a new entry to the internal lists
 # 
BEGIN{$TYPEINFO{AddEntry}=["function", "boolean", "string",["map", "string","string"]];}
sub AddEntry {
	my $self  = shift;
	my $name  = shift;
	my $entry = shift;
	y2milestone("------AddEntry------");
	push @{$Maps->{$name}->{'entries'}} , $entry;
}

##
 # Delete an entry from a map in the internal lists
 # 
BEGIN{$TYPEINFO{DelEntry}=["function", "boolean", "string", "string"];}
sub DelEntry {
	my $self = shift;
	my $key  = shift;
	my $map  = shift;
	y2milestone("------DelEntry------$map:$key");
	my @entries = ();

	foreach my $entry (@{$Maps->{$map}->{'entries'}})
	{
	   if( $entry->{'key'} ne $key )
	   {
	     push @entries, $entry;
	   }
	}
	$Maps->{$map}->{'entries'} = \@entries;
}

# Export
BEGIN{$TYPEINFO{GetEntriesOfMap}=["function", ["list", ["map","string","string"]],"string"];}
sub GetEntriesOfMap {
	my $self  = shift;
	my $name  = shift;
	y2milestone("------GetEntriesOfMap------");
	return $Maps->{$name}->{'entries'};
}


##
 # The LDAPServer
 #
my $LDAPServer = undef;

##
 # Is the system configured as LDAP-Client?
 # @return true if the system is configured as LDAP-Client
 #
BEGIN { $TYPEINFO {CheckLDAP} = ["function", "boolean"]; }
sub CheckLDAP
{
	my $self      = shift;
	my $success   = 0;

	y2milestone("------Starting CheckLDAP ------");
	Ldap->Read();
	$ldapMap = Ldap->Export();
	if( ! $ldapMap->{base_config_dn} )
	{
	   y2milestone("------LDAP_CLIENT_NOT_CONFIGURED------");
	   return YaPI->SetError( summary => __("You must configure LDAP to use the autofs modul.").
					     "\n".
					     __("You can do it by using the YaST2 ldap modul."),
	                           code   => "LDAP_CLIENT_NOT_CONFIGURED" );
	}
	$LDAPServer = $ldapMap->{ldap_server};
	if( $LDAPServer eq 'localhost' || $LDAPServer eq '127.0.0.1' )
	{
	   $LDAPServer = `cat /etc/HOSTNAME`; chomp $LDAPServer;
	   $LDAPServer = AutofsUI->GetLDAPServer($LDAPServer);
	   if( $LDAPServer eq 'no' )
	   {
	       y2milestone("------UNSUITABLE_LDAP_SERVER------");
	       return YaPI->SetError( summary => __("Cannot use localhost as the LDAP server for autofs."),
	                           code    => "UNSUITABLE_LDAP_SERVER" );
	   }
	}
	
	# Now we initalize the ldap connection
	y2milestone("------Init LDAP------");
	Ldap->LDAPInit();
	$AUTOFSBase     = "ou=autofs,".$ldapMap->{ldap_domain};
	$AutoMasterBase = "nisMapName=auto.master,".$AUTOFSBase;
	
	# Now we make the ldap bind
	$success = Ldap->LDAPAskAndBind(Boolean(0));
	if( ! $success )
	{
	   y2milestone("------CAN_NOT_BIND_LDAP------");
	   return YaPI->SetError( summary => __("Failed to bind to the LDAP server."),
	                           code    => "CAN_NOT_BIND_LDAP"  );
	}

	$success = SCR->Read ('.ldap.search', {
	                "base_dn"      => $AUTOFSBase,
	                "filter"       => "(objectclass=*)",
	                "scope"        => 0,
	                "not_found_ok" => Boolean(0),
	                "dn_only"      => Boolean(1)
	            }
	        );
	if( ! $success )
	{
	  return CreateAutoFSBase();
	}
	return Boolean(1);
}

##
 # Creates the autofs baseDN and the automaster entry
 # @return true if the autofs baseDN and the automaster entry were created succesfully
 #
BEGIN { $TYPEINFO {CreateAutoFSBase} = ["function", "boolean"]; }
sub CreateAutoFSBase
{
	my $self            = shift;
	my $success         = shift;
	
	y2milestone("------Starting CreateAutoFSBase ------");
	
	$success = SCR->Write(".ldap.add", { "dn" => $AUTOFSBase } ,
	                        {
	                          "objectClass" => "organizationalUnit",
	                          "ou"          => "autofs"
	                        }
	          );
	$success = SCR->Write(".ldap.add", { "dn" => $AutoMasterBase },
	                        {
	                          "objectClass" => [ "nismap"],
	                          "nisMapName"  => "auto.master"
	                        }
	          );
	if( $success )
	{
	   return Boolean(1);
	}
	return YaPI->SetError( summary => __("Failed to create the autofs base objects."),
	                        code    => "CREATE_AUTOFSBASE_FAILED" );
}

##
 # Add a new map to the ldap configurarion
 # @return true if the adding of the new map was successfully
 #
BEGIN { $TYPEINFO {AddMapToLDAP} = ["function", "boolean","string"]; }
sub AddMapToLDAP
{
	my $self            = shift;
	my $name            = shift;
	my $success;
	
	y2milestone("------Starting AddMapToLDAP ------");
	
	$success = SCR->Write(".ldap.add", { "dn" => "cn=/$name,$AutoMasterBase" },
	                        { 
	                          "objectClass" => [ "nisObject"],
	                          "nisMapName"  => "auto.master",
	                          "cn"          => "/$name",
	                          "nisMapEntry" => "ldap ".$LDAPServer.":nisMapName=auto.".$name.",".$AUTOFSBase
	                         }
	          );
	$success = SCR->Write(".ldap.add", { "dn" => "nisMapName=auto.$name,$AUTOFSBase" },
	                        { 
	                          "objectClass"=> [ "nismap"],
	                          "nisMapName" => "auto.$name"
	                        }
	          );
	$Maps->{$name}->{dn} = "nisMapName=auto.$name,$AUTOFSBase";	  
	if( $success )
	{
	   return Boolean(1);
	}
	return YaPI->SetError( summary => __("Failed to create the new map."),
	                        code    => "CREATE_MAP_FAILED" );
}

##
 # Delete a map and all its entries from the ldap configurarion
 # @return true if the removing of the map was successfully
 #
BEGIN { $TYPEINFO {DelMapFromLDAP} = ["function", "boolean","string"]; }
sub DelMapFromLDAP
{
	my $self            = shift;
	my $name            = shift;
	my $success;
	
	y2milestone("------Starting AddMapToLDAP ------");
	
	$success = SCR->Write(".ldap.delete", { "dn" => "cn=/$name,$AutoMasterBase" });
	$success = SCR->Write(".ldap.delete", { "dn" => "nisMapName=auto.$name,$AUTOFSBase", subtree => Boolean(1)});

	if( $success )
	{
	   return Boolean(1);
	}
	return YaPI->SetError( summary => __("Failed to delete an autofs map."),
	                        code   => "DELETE_MAP_FAILED" );
}

##
 # Add a new entry to an existing map
 # @return true if the adding of the new entry was successfully
 #
BEGIN { $TYPEINFO {AddEntryToLDAP} = ["function", "boolean","string", ["map","string","string"]]; }
sub AddEntryToLDAP
{
	my $self            = shift;
	my $map             = shift;
	my $entry           = shift;
	my $dn              = "cn=$entry->{'key'},$Maps->{$map}->{'dn'}";
	my $success;
	  
	y2milestone("------Starting AddEntr ------");
	
	$success = SCR->Write(".ldap.add", { "dn" => $dn },
	                       { 
	                         "objectClass" => [ "nisObject"],
	                         "nisMapName"  => "auto.$map",
	                         "cn"          => "$entry->{'key'}",
	                         "nisMapEntry" => $entry->{options}." ".$entry->{location}
	                        }
	         );
	if( ! $success )
	{
	   return YaPI->SetError( summary => __("Failed to add an autofs entry to map.")." : ".$map,
	                           code    => "ADD_ENTRY_FAILED" );
	}
	$Maps->{$map}->{'dns'}->{$dn} = 1;
	return Boolean(1);
}

##
 # Modify an entry to an existing map
 # @return true if the modifying of the entry was successfully
 #
BEGIN { $TYPEINFO {ModifyEntryInLDAP} = ["function", "boolean","string", ["map","string","string"]]; }
sub ModifyEntryInLDAP
{
	my $self            = shift;
	my $map             = shift;
	my $entry           = shift;
	my $success;
	
	$success = SCR->Write(".ldap.modify", { "dn" => $entry->{'dn'} },
	                       { 
	                         "objectClass" => [ "nisObject"],
	                         "nisMapName"  => "auto.$map",
	                         "cn"          => "$entry->{'key'}",
	                         "nisMapEntry" => $entry->{options}." ".$entry->{location}
	                        }
	         );
	if( ! $success )
	{
	   return YaPI->SetError( summary => __("Failed to modify an autofs entry in map.")." : ".$map,
	                           code    => "MODIFY_ENTRY_FAILED" );
	}
	return Boolean(1);
}

##
 # Read the autofs maps and saves its baseDNs and a empty list for the entries into the global array $Maps.
 # @return the count of the maps.
 #
BEGIN { $TYPEINFO {ReadMaps} = ["function", "integer"]; }
sub ReadMaps
{
	my $self            = shift;
	
	y2milestone("------Starting ReadMaps ------");
	my $all = SCR->Read ('.ldap.search', {
	                "base_dn"      => $AUTOFSBase,
	                "filter"       => "(!(nisMapName=auto.master))",
	                "scope"        => 1,
	                "not_found_ok" => Boolean(1),
	                "dn_only"      => Boolean(1)
	            }
	        );
	my $count = 0;	
	foreach my $dn (@{$all})
	{
		$count++;
	  $dn =~ /nisMapName=auto\.(.*),$AUTOFSBase/i;
	  $Maps->{$1}->{dn}      = $dn;
	  $Maps->{$1}->{entries} = [];
	  $Maps->{$1}->{dns}     = {};
	  $self->ReadEntriesOfMap($1);
	}
	return 1;
}

##
 # Read the entries of a map and saves this into the global hash Maps
 # @return the count of the entries in a map
 #
BEGIN { $TYPEINFO {ReadEntriesOfMap} = ["function", "integer","string"]; }
sub ReadEntriesOfMap
{
	my $self           = shift;
	my $map            = shift;

	y2milestone("------Starting ReadEntriesOfMap $map ------");

	my $all = SCR->Read ('.ldap.search', {
	                  "base_dn"      => $Maps->{$map}->{dn},
	                  "filter"       => "(objectClass=nisObject)",
	                  "scope"        => 1,
	  		  "map"          => 1,
	                  "not_found_ok" => Boolean(1)
	          }
	);
	my $count = 0;	
	foreach my $dn (keys %{$all})
	{
		$count++;
		my $Entry  = {};
		$Entry->{'key'}      = $all->{$dn}->{'cn'}->[0];
		$Entry->{'dn'}       = $dn;
		$Maps->{$map}->{dns}->{$dn} = 0;
		my ($options,$location)    = split /\s+/,$all->{$dn}->{'nismapentry'}->[0],2;
		$Entry->{'options'}  = $options;
		$Entry->{'location'} = $location;
		$Entry->{'modified'} = "0";
		push @{$Maps->{$map}->{entries}}, $Entry;
	}
}

##
 # Writes the autofs maps and their entries into the LDAP
 # @return tru if it was successfuly.
 #
BEGIN { $TYPEINFO {WriteAutofsMapsToLDAP} = ["function", "boolean"]; }
sub WriteAutofsMapsToLDAP
{
	my $self            = shift;
	y2milestone("------Starting WriteAutofsMapsToLDAP ------");

	foreach my $map (keys %{$Maps})
	{
	   if( $Maps->{$map}->{'deleted'}  && $Maps->{$map}->{'dn'} ne "" )
	   { # Remove map
	      $self->DelMapFromLDAP($map);
	      next;
	   }
	   if( !$Maps->{$map}->{'deleted'} && $Maps->{$map}->{'dn'} eq ""  )
	   { # Add a new map
	      $self->AddMapToLDAP($map);
	   }
	   foreach my $entry (@{$Maps->{$map}->{entries}})
	   {
	      if( !defined $entry->{dn} )
	      { # This is a new entry
	         $self->AddEntryToLDAP($map,$entry);
		 next;
	      }
	      $Maps->{$map}->{'dns'}->{$entry->{'dn'}} = 1;
	      if( $entry->{'modified'} )
	      { # This entry was modified
	        $self->ModifyEntryInLDAP($map,$entry);
	      }
	   }
	   foreach my $dn ( keys %{$Maps->{$map}->{'dns'}} )
	   {
	      if( ! $Maps->{$map}->{'dns'}->{$dn} )
	      { # This entry was deleted
	        SCR->Write('.ldap.delete',{ dn => $dn, subtree => Boolean(1) });
	      }
	   }
	}
	return 1;
}

##
 # Data was modified?
 # @return true if modified
 #
BEGIN { $TYPEINFO {Modified} = ["function", "boolean"]; }
sub Modified {
    y2debug ("modified=$modified");
    return Boolean($modified);
}

# Settings: Define all variables needed for configuration of autofs
# TODO FIXME: Define all the variables necessary to hold
# TODO FIXME: the configuration here (with the appropriate
# TODO FIXME: description)
# TODO FIXME: For example:
#   ##
#    # List of the configured cards.
#    #
#   my @cards = ();
#
#   ##
#    # Some additional parameter needed for the configuration.
#    #
#   my $additional_parameter = 1;

##
 # Read all autofs settings
 # @return true on success
 #
BEGIN { $TYPEINFO{Read} = ["function", "boolean"]; }
sub Read {
	my $self            = shift;

	# Autofs read dialog caption
	my $caption = __("Initializing autofs Configuration");
	
	# TODO FIXME Set the right number of stages
	my $steps = 3;
	
	my $sl = 0.5;
	sleep($sl);
	
	y2milestone("------Starting Read ------");
	
	# TODO FIXME Names of real stages
	# We do not set help text here, because it was set outside
	Progress->New( $caption, " ", $steps, [
	        # Progress stage 1/2
	        __("Check the ldap configuration"),
	        # Progress stage 2/2
	        __("Read the autofs maps")
	    ], [
	        # Progress step 1/2
	        __("Checking the ldap configuration..."),
	        # Progress step 2/2
	        __("Reading the autofs maps..."),
	        # Progress finished
	        __("Finished")
	    ],
	    ""
	);
	
	# read database
	Progress->NextStage();
	# Error message
	if(! $self->CheckLDAP())
	{
	    my $ERROR = __("LDAP configuration error.");
	    my $error = YaPI->Error;
	    if(defined $error->{description} && $error->{description} ne "")
	    {
	      $ERROR .= "\n".$error->{description};
	    }  
	    if(defined $error->{summary} && $error->{summary} ne "")
	    {
	      $ERROR .= "\n".$error->{summary};
	    }  
	    return Popup->Error($ERROR);
	}
	# read database
	Progress->NextStage();
	# Error message
	if(! $self->ReadMaps())
	{
	    my $ERROR = __("Cannot read the autofs maps.");
	    my $error = YaPI->Error;
	    if(defined $error->{description} && $error->{description} ne "")
	    {
	      $ERROR .= "\n".$error->{description};
	    }  
	    if(defined $error->{summary} && $error->{summary} ne "")
	    {
	      $ERROR .= "\n".$error->{summary};
	    }  
	    return Popup->Error($ERROR);
	}
	sleep($sl);
	
	# Progress finished
	Progress->NextStage();
	sleep($sl);
	
	$modified = 0;
	return Boolean(1);
}

##
 # Write all autofs settings
 # @return true on success
 #
BEGIN { $TYPEINFO{Write} = ["function", "boolean"]; }
sub Write {
	my $self            = shift;

	# Autofs read dialog caption
	my $caption = __("Saving autofs Configuration");
	
	# TODO FIXME And set the right number of stages
	my $steps = 1;
	
	my $sl = 0.5;
	sleep($sl);
	
	# TODO FIXME Names of real stages
	# We do not set help text here, because it was set outside
	Progress->New($caption, " ", $steps, [
	        # Progress stage 1/1
	        __("Write the autofs maps")
	    ], [
	        # Progress step 1/1
	        __("Writing the autofs maps..."),
	        # Progress finished
	        __("Finished")
	    ],
	    ""
	);
	
	# write settings
	Progress->NextStage();
	# Error message
	if(! $self->WriteAutofsMapsToLDAP())
	{
	    Popup->Error (__("Cannot write the autofs maps."));
	}
	sleep($sl);
	
	# Progress finished
	Progress->NextStage();
	sleep($sl);
	
	return Boolean(1);
}

##
 # Get all autofs settings from the first parameter
 # (For use by autoinstallation.)
 # @param settings The YCP structure to be imported.
 # @return boolean True on success
 #
BEGIN { $TYPEINFO{Import} = ["function", "boolean", [ "map", "any", "any" ] ]; }
sub Import {
    my %settings = %{$_[0]};
    # TODO FIXME: your code here (fill the above mentioned variables)...
    return Boolean(1);
}

##
 # Dump the autofs settings to a single map
 # (For use by autoinstallation.)
 # @return map Dumped settings (later acceptable by Import ())
 #
BEGIN { $TYPEINFO{Export}  =["function", [ "map", "any", "any" ] ]; }
sub Export {
    # TODO FIXME: your code here (return the above mentioned variables)...
    return {};
}

##
 # Create a textual summary and a list of unconfigured cards
 # @return summary of the current configuration
 #
BEGIN { $TYPEINFO{Summary} = ["function", [ "list", "string" ] ]; }
sub Summary {
    # TODO FIXME: your code here...
    # Configuration summary text for autoyast
    return (
	__("Configuration summary ...")
    );
}

##
 # Create an overview table with all configured cards
 # @return table items
 #
BEGIN { $TYPEINFO{Overview} = ["function", [ "list", "string" ] ]; }
sub Overview {
    # TODO FIXME: your code here...
    return ();
}

##
 # Return packages needed to be installed and removed during
 # Autoinstallation to insure module has all needed software
 # installed.
 # @return map with 2 lists.
 #
BEGIN { $TYPEINFO{AutoPackages} = ["function", ["map", "string", ["list", "string"]]]; }
sub AutoPackages {
    # TODO FIXME: your code here...
    my %ret = (
	"install" => (),
	"remove" => (),
    );
    return \%ret;
}

1;
# EOF
