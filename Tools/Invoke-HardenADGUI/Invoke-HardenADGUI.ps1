# get root path of the solution
$scriptRootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

$configXMLFilePath = Join-Path -Path $scriptRootPath -ChildPath "Configs\TasksSequence_HardenAD.xml"

$configXMLFileName = $configXMLFilePath | Split-Path -Leaf

$xmlModule = "$scriptRootPath\Modules\module-fileHandling\module-fileHandling.psm1"
Import-Module "$xmlModule"

$TasksSeqConfig = [xml](Get-Content $configXMLfilePath -Encoding utf8)

$Tasks = $TasksSeqConfig.Settings.Sequence.ID | Sort-Object Number

[System.Collections.Generic.List[PSObject]]$rowArray = @()
[System.Collections.Generic.List[PSObject]]$checkboxesArray = @()

for ($i = 0; $i -lt $Tasks.Count; $i++) {
	$task = $Tasks[$i]
	# Add a new row definition every 2 tasks because we have 2 columns
	if ($i % 2 -eq 0) {
		$rowArray.Add("<RowDefinition Height='*'></RowDefinition>")
	}
	# Calculate the row and column for the current task
	$row = [Math]::Floor($i / 2)
	# If the task is on an even index, it will be on the first column, otherwise it will be on the second column
	$column = $i % 2

	# Check if the task is enabled. If it is, the checkbox will be checked, otherwise it will be unchecked
	$taskEnabled = $task.TaskEnabled -eq 'Yes'
	$taskDescription = $task.TaskDescription.Replace("'", "").Replace("`(", '')

	$checkboxesArray.Add("<CheckBox x:Name='ID_$($task.Number)' Content='$($task.Number) - $($task.Name)' IsChecked='$taskEnabled' Grid.Row='$row' Grid.Column='$column' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='1, 1, 1, 1' ToolTip='$taskDescription' />")
}

$groupPolicies = $TasksSeqConfig.Settings.GroupPolicies.GPO

[System.Collections.Generic.List[PSObject]]$groupPoliciesRowsArray = @()
[System.Collections.Generic.List[PSObject]]$groupPoliciesCheckboxesArray = @()
$gpoGUIDHashTables = @{}

for ($i = 0; $i -lt $groupPolicies.Count; $i++) {
	$gpoGUIDHashTables.Add($i, $groupPolicies[$i].BackupID)

	# Add a new row definition every 4 gpos because we have 4 columns
	if ($i % 4 -eq 0) {
		$groupPoliciesRowsArray.Add("<RowDefinition Height='*'></RowDefinition>")
	}
	# Calculate the row and column for the current gpo
	$row = [Math]::Floor($i / 4)
	# If the gpo is on an index that modulo 4 gives 0, 1, 2 or 3, it will be on the first, second, third or fourth column respectively
	$column = $i % 4

	$groupPolicy = $groupPolicies[$i]
	$groupPolicyName = $groupPolicy.Name
	#$groupPolicyDescription = $groupPolicy.Description.Replace("'", "").Replace("`(", '')
	$groupPolicyEnabled = $groupPolicy.Validation -eq 'Yes'

	$groupPoliciesCheckboxesArray.Add("<CheckBox x:Name='ID_$i' Content='$groupPolicyName' IsChecked='$groupPolicyEnabled' Grid.Row='$row' Grid.Column='$column' HorizontalAlignment='Left' VerticalAlignment='Center' Margin='1, 1 ,1, 1' />")
}

Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, WindowsFormsIntegration
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$labelText1 = "To prevent accidental changes, all the tasks are disabled by default in the XML configuration file."
$labelText2 = "Select the tasks you want to enable/disable and click Save."
$labelText3 = "The only purpose of the GUI is to configure HardenAD config file, it does not perform any actions!"

$icon = "$PSScriptRoot\hardenAD.ico"

<#
<?xml version="1.0" encoding="utf-8"?>
<Settings>
	<!--
  		Revision: 2024/04/13 - contact@hardenad.net
	-->
	<Version>
		<Edition Name="Community Edition" />
		<Release Major="02" Minor="09" BugFix="008" />
	</Version>
	<History>
		<LastRun Date="" System="" isPDCemulator="" />
		<Domains Root="" Domain="" />
		<Script SourcePath="" />
	</History>
	<OrganizationalUnits>
		<!-- 
			The section <ouTree> handle the base model for OU creation.
    		When calling the function [Set-OUTree], you need to add as parameter the "OU class" name of the tree structure you want to add.
    		This could also be used to manage new OU generation.
		-->
		<ouTree>
			<!-- 
				CLASS: HardenAD_ADMIN
      			This class generate an OU tree used for administration purpose in a tiering model. This is the English Edtion.
			-->
			<OU Class="HardenAD_ADMIN" Name="_Administration" Description="Privileged accounts administrative OU">
				<ChildOU Name="GroupsT0" Description="Groups to manage Tier 0 objects">
					<ChildOU Name="Deleg" Description="Groups used to delegate permissions on AD objects" />
					<ChildOU Name="GPO" Description="Groups used to allow or deny settings via Group Policies Objects" />
					<ChildOU Name="LocalAdmins" Description="Groups used to grant a user being local administrator of a resource" />
					<ChildOU Name="Logon" Description="Groups used to login access to a resource" />
				</ChildOU>
				<ChildOU Name="GroupsT1" Description="Groups to manage Tier 1 objects">
					<ChildOU Name="Deleg" Description="Groups used to delegate permissions on AD objects" />
					<ChildOU Name="GPO" Description="Groups used to allow or deny settings via Group Policies Objects" />
					<ChildOU Name="LocalAdmins" Description="Groups used to grant a user being local administrator of a resource" />
				</ChildOU>
				<ChildOU Name="GroupsT1L" Description="Groups to manage Tier 1 Legacy objects">
					<ChildOU Name="Deleg" Description="Groups used to delegate permissions on AD objects" />
					<ChildOU Name="GPO" Description="Groups used to allow or deny settings via Group Policies Objects" />
					<ChildOU Name="LocalAdmins" Description="Groups used to grant a user being local administrator of a resource" />
				</ChildOU>
				<ChildOU Name="GroupsT2" Description="Groups to manage Tier 2 objects">
					<ChildOU Name="Deleg" Description="Groups used to delegate permissions on AD objects" />
					<ChildOU Name="GPO" Description="Groups used to allow or deny settings via Group Policies Objects" />
					<ChildOU Name="LocalAdmins" Description="Groups used to grant a user being local administrator of a resource" />
				</ChildOU>
				<ChildOU Name="GroupsT2L" Description="Groups to manage Tier 1 Legacy objects">
					<ChildOU Name="Deleg" Description="Groups used to delegate permissions on AD objects" />
					<ChildOU Name="GPO" Description="Groups used to allow or deny settings via Group Policies Objects" />
					<ChildOU Name="LocalAdmins" Description="Groups used to grant a user being local administrator of a resource" />
				</ChildOU>
				<ChildOU Name="PawAccess" Description="First Node Privilege Admin Worstations" />
				<ChildOU Name="PawT0" Description="Privilege Admin Worstations Tier 0 assets" />
				<ChildOU Name="PawT12L" Description="Privilege Admin Worstations for Tier 1, Tier 2 and Tier Legacy assets" />
				<ChildOU Name="UserAccess" Description="First User Node Privilege Admin Worstations" />
				<ChildOU Name="UsersT0" Description="Users to manage Tier 0 objects" />
				<ChildOU Name="UsersT1" Description="Users to manage Tier 1 objects" />
				<ChildOU Name="UsersT1L" Description="Users to manage Tier 1 Legacy objects" />
				<ChildOU Name="UsersT2" Description="Users to manage Tier 2 objects" />
				<ChildOU Name="UsersT2L" Description="Users to manage Tier 1 Legacy objects" />
			</OU>
			<!--
				CLASS: HardenAD_PROD-T0
      			This class generate an OU tree used for administration purpose in a tiering model. This is the English Edtion.
			-->
			<OU Class="HardenAD_PROD-T0" Name="Harden_T0" Description="Tier 0 resources">
				<ChildOU Name="Groups" Description="Groups objects belonging to this Tier" />
				<ChildOU Name="Servers" Description="Computer objects belonging to this Tier and acting as servers">
					<ChildOU Name="Disabled" Description="Disabled computer objects" />
				</ChildOU>
				<ChildOU Name="Services" Description="Service accounts belonging to this Tier">
					<ChildOU Name="Disabled" Description="Disabled sevice accounts" />
				</ChildOU>
				<ChildOU Name="Users" Description="User objects belonging to this Tier">
					<ChildOU Name="Disabled" Description="Disabled user objects" />
				</ChildOU>
				<ChildOU Name="Workstations" Description="Computer Objects belonging to this Tier and acting as clients">
					<ChildOU Name="Disabled" Description="Disabled computer objects" />
				</ChildOU>
			</OU>
			<!-- 
				CLASS: HardenAD_PROD-T1and2
				This class generate an OU tree used for administration purpose in a tiering model. This is the English Edtion.
			-->
			<OU Class="HardenAD_PROD-T1and2" Name="Harden_T12" Description="Tier 1 and Tier 2 resources">
				<ChildOU Name="Contacts" Description="Contacts objects belonging to this Tier" />
				<ChildOU Name="Groups" Description="Groups objects belonging to this Tier" >
					<ChildOU Name="AADSync" Description="Groups objects synced with Azure AD" />
				</ChildOU>
				<ChildOU Name="Servers" Description="Computer objects belonging to this Tier and acting as servers">
					<ChildOU Name="Disabled" Description="Disabled computer objects" />
				</ChildOU>
				<ChildOU Name="Services" Description="Service accounts belonging to this Tier">
					<ChildOU Name="Disabled" Description="Disabled sevice accounts" />
				</ChildOU>
				<ChildOU Name="Users" Description="User objects belonging to this Tier">
					<ChildOU Name="AADSync" Description="User objects synced with Azure AD" />
					<ChildOU Name="Disabled" Description="Disabled user objects" />
				</ChildOU>
				<ChildOU Name="Workstations" Description="Computer Objects belonging to this Tier and acting as clients">
					<ChildOU Name="AADSync" Description="Computer objects synced with Azure AD" />
					<ChildOU Name="Disabled" Description="Disabled computer objects" />
				</ChildOU>
			</OU>
			<!-- 
				CLASS: HardenAD_PROD-LEGACY
				This class generate an OU tree used for administration purpose in a tiering model. This is the English Edtion.
			-->
			<OU Class="HardenAD_PROD-LEGACY" Name="Harden_TL" Description="Legacy resources">
				<ChildOU Name="Groups" Description="Groups objects belonging to this Tier" >
					<ChildOU Name="AADSync" Description="Groups objects synced with Azure AD" />
				</ChildOU>
				<ChildOU Name="Servers" Description="Computer objects belonging to this Tier and acting as servers">
					<ChildOU Name="Disabled" Description="Disabled computer objects" />
				</ChildOU>
				<ChildOU Name="Services" Description="Service accounts belonging to this Tier">
					<ChildOU Name="Disabled" Description="Disabled sevice accounts" />
				</ChildOU>
				<ChildOU Name="Users" Description="User objects belonging to this Tier">
					<ChildOU Name="AADSync" Description="User objects synced with Azure AD" />
					<ChildOU Name="Disabled" Description="Disabled user objects" />
				</ChildOU>
				<ChildOU Name="Workstations" Description="Computer Objects belonging to this Tier and acting as clients">
					<ChildOU Name="AADSync" Description="Computer objects synced with Azure AD" />
					<ChildOU Name="Disabled" Description="Disabled computer objects" />
				</ChildOU>
			</OU>
			<!-- 
				CLASS: PROVISIONNING-EN
				This class generate an OU tree used for provisioning objects in a default location. This is the English Edition.
			-->
			<OU Class="PROVISIONNING-EN" Name="Provisioning" Description="New objects provisioning OU">
				<ChildOU Name="Users" Description="New user objects" />
				<ChildOU Name="Computers" Description="New computer objects" />
			</OU>
		</ouTree>
	</OrganizationalUnits>
	<DelegationACEs>
		<!-- 
			This section push delegation ACL to designated OU Administration ==============
			Delegation for L-S-T1-DELEG_Group - Create and Delete (administration) 
		-->
		<ACL Trustee="L-S-T1-DELEG_Group - Create and Delete (administration)" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="group" TargetDN="OU=GroupsT1,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Group - Create and Delete (administration)" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="Group" ObjectType="" TargetDN="OU=GroupsT1,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Group - Create and Delete (administration)" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="group" TargetDN="OU=GroupsT1L,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Group - Create and Delete (administration)" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="Group" ObjectType="" TargetDN="OU=GroupsT1L,OU=_Administration,ROOTDN" />
		<!-- 
			Delegation for L-S-T2-DELEG_Group - Create and Delete (administration) 
		-->
		<ACL Trustee="L-S-T2-DELEG_Group - Create and Delete (administration)" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="group" TargetDN="OU=GroupsT2,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_Group - Create and Delete (administration)" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="Group" ObjectType="" TargetDN="OU=GroupsT2,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_Group - Create and Delete (administration)" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="group" TargetDN="OU=GroupsT2L,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_Group - Create and Delete (administration)" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="Group" ObjectType="" TargetDN="OU=GroupsT2L,OU=_Administration,ROOTDN" />
		<!-- 
			Delegation for L-S-T1-DELEG_User - Create and Delete (administration) 
		-->
		<ACL Trustee="L-S-T1-DELEG_User - Create and Delete (administration)" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="user" TargetDN="OU=UsersT1,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_User - Create and Delete (administration)" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="user" ObjectType="" TargetDN="OU=UsersT1,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_User - Create and Delete (administration)" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="user" TargetDN="OU=UsersT1L,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_User - Create and Delete (administration)" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="user" ObjectType="" TargetDN="OU=UsersT1L,OU=_Administration,ROOTDN" />
		<!-- 
			Delegation for L-S-T2-DELEG_User - Create and Delete (administration) 
		-->
		<ACL Trustee="L-S-T2-DELEG_User - Create and Delete (administration)" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="user" TargetDN="OU=UsersT2,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_User - Create and Delete (administration)" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="user" ObjectType="" TargetDN="OU=UsersT2,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_User - Create and Delete (administration)" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="user" TargetDN="OU=UsersT2L,OU=_Administration,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_User - Create and Delete (administration)" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="user" ObjectType="" TargetDN="OU=UsersT2L,OU=_Administration,ROOTDN" />
		<!-- Production ==========
			Delegation for L-S-T1-DELEG_Computer - Create and Delete 
		-->
		<ACL Trustee="L-S-T1-DELEG_Computer - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="computer" TargetDN="OU=Servers,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Computer - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="computer" ObjectType="" TargetDN="OU=Servers,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Computer - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="computer" TargetDN="OU=Servers,OU=Harden_TL,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Computer - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="computer" ObjectType="" TargetDN="OU=Servers,OU=Harden_TL,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Computer - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="computer" TargetDN="OU=Computers,OU=Provisioning,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Computer - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="computer" ObjectType="" TargetDN="OU=Computers,OU=Provisioning,ROOTDN" />
		<!-- 
			Delegation for L-S-T1-DELEG_User - Create and Delete 
		-->
		<ACL Trustee="L-S-T1-DELEG_User - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="user" TargetDN="OU=Services,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_User - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="user" ObjectType="" TargetDN="OU=Services,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_User - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="user" TargetDN="OU=Services,OU=Harden_TL,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_User - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="user" ObjectType="" TargetDN="OU=Services,OU=Harden_TL,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_User - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="user" TargetDN="OU=Users,OU=Provisioning,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_User - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="user" ObjectType="" TargetDN="OU=Users,OU=Provisioning,ROOTDN" />
		<!-- 
			Delegation for L-S-T2-DELEG_Computer - Create and Delete 
		-->
		<ACL Trustee="L-S-T2-DELEG_Computer - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="computer" TargetDN="OU=Workstations,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_Computer - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="computer" ObjectType="" TargetDN="OU=Workstations,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_Computer - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="computer" TargetDN="OU=Workstations,OU=Harden_TL,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_Computer - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="computer" ObjectType="" TargetDN="OU=Workstations,OU=Harden_TL,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_Computer - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="computer" TargetDN="OU=Computers,OU=Provisioning,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_Computer - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="computer" ObjectType="" TargetDN="OU=Computers,OU=Provisioning,ROOTDN" />
		<!-- 
			Delegation for L-S-T1-DELEG_Group - Create and Delete 
		-->
		<ACL Trustee="L-S-T1-DELEG_Group - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="group" TargetDN="OU=Groups,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Group - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="group" ObjectType="" TargetDN="OU=Groups,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Group - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="group" TargetDN="OU=Groups,OU=Harden_TL,ROOTDN" />
		<ACL Trustee="L-S-T1-DELEG_Group - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="group" ObjectType="" TargetDN="OU=Groups,OU=Harden_TL,ROOTDN" />
		<!-- 
			Delegation for L-S-T2-DELEG_contact - Create and Delete 
		-->
		<ACL Trustee="L-S-T2-DELEG_Contact - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="contact" TargetDN="OU=contacts,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_Contact - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="contact" ObjectType="" TargetDN="OU=Contacts,OU=Harden_T12,ROOTDN" />
		<!-- 
			Delegation for L-S-T2-DELEG_User - Create and Delete 
		-->
		<ACL Trustee="L-S-T2-DELEG_User - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="user" TargetDN="OU=Users,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_User - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="user" ObjectType="" TargetDN="OU=Users,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_User - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="user" TargetDN="OU=Users,OU=Harden_TL,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_User - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="user" ObjectType="" TargetDN="OU=Users,OU=Harden_TL,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_User - Create and Delete" Right="CreateChild, DeleteChild" RightType="Allow" Inheritance="All" InheritedObjects="" ObjectType="user" TargetDN="OU=Users,OU=Provisioning,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_User - Create and Delete" Right="GenericAll" RightType="Allow" Inheritance="Descendents" InheritedObjects="user" ObjectType="" TargetDN="OU=Users,OU=Provisioning,ROOTDN" />
		<!-- 
			Delegation for L-S-T2-DELEG_Group - Manage Membership 
		-->
		<ACL Trustee="L-S-T2-DELEG_Group - Manage Membership" Right="ReadProperty, WriteProperty" RightType="Allow" Inheritance="Descendents" InheritedObjects="group" ObjectType="" TargetDN="OU=Groups,OU=Harden_T12,ROOTDN" />
		<ACL Trustee="L-S-T2-DELEG_Group - Manage Membership" Right="ReadProperty, WriteProperty" RightType="Allow" Inheritance="Descendents" InheritedObjects="group" ObjectType="" TargetDN="OU=Groups,OU=Harden_TL,ROOTDN" />
		<!-- 
			Delegation for auditing computer creation and deletion 
		-->
		<!-- EN-US - START -->
		<ACL Audit="True" Trustee="Domain Users" Right="CreateChild, DeleteChild" RightType="Success" Inheritance="All" InheritedObjects="" ObjectType="computer" TargetDN="ROOTDN" />
		<!-- EN-US - END   -->
		<!-- FR-FR - START -->
		<!--
		<ACL Audit="True" Trustee="Utilisateurs du domaine" Right="CreateChild, DeleteChild" RightType="Success" Inheritance="All" InheritedObjects="" ObjectType="computer" TargetDN="ROOTDN" />
		-->
		<!-- FR-FR - END   -->
		<!--
			Custom Access Rule: allow domain join only
		-->
		<SDDL Trustee="L-S-T0-DELEG_Computer - Join Domain" CustomAccessRule="Computer_DomJoin" TargetDN="OU=Workstations,OU=Harden_T0,ROOTDN" />
		<SDDL Trustee="L-S-T1-DELEG_Computer - Join Domain" CustomAccessRule="Computer_DomJoin" TargetDN="OU=Servers,OU=Harden_T12,ROOTDN" />
		<SDDL Trustee="L-S-T1-DELEG_Computer - Join Domain" CustomAccessRule="Computer_DomJoin" TargetDN="OU=Computers,OU=Provisioning,ROOTDN" />
		<SDDL Trustee="L-S-T2-DELEG_Computer - Join Domain" CustomAccessRule="Computer_DomJoin" TargetDN="OU=Workstations,OU=Harden_T12,ROOTDN" />
		<SDDL Trustee="L-S-T2-DELEG_Computer - Join Domain" CustomAccessRule="Computer_DomJoin" TargetDN="OU=Computers,OU=Provisioning,ROOTDN" />
	</DelegationACEs>
	<Translation>
		<!-- 
			This section create a reference table to be used through the scripts
			For now, only the GPO parts use this dynamic logic to fillup the migration and the preference table.
			> WellKnownID..: used to replace a dynamic pattern in a name (group, user, path, gpo, ...)
			> Keyword......: used to shorten a word in a name (group, user, path, gpo, ...), helping in avoiding too long name in AD

			The french edition is commented: you can use it by removing the english translation and uncoment each line.
		-->
		<!-- EN-US - START -->
		<wellKnownID objectClass="text" translateFrom="%Administrators%" translateTo="Administrators" />
		<wellKnownID objectClass="text" translateFrom="%DomainAdmins%" translateTo="Domain Admins" />
		<wellKnownID objectClass="text" translateFrom="%SchemaAdmins%" translateTo="Schema Admins" />
		<wellKnownID objectClass="text" translateFrom="%EnterpriseAdmins%" translateTo="Enterprise Admins" />
		<wellKnownID objectClass="text" translateFrom="%Users%" translateTo="Users" />
		<wellKnownID objectClass="text" translateFrom="%Guest%" translateTo="Guest" />
		<!-- EN-US - END   -->
		<!-- FR-FR - START -->
		<!--
		<wellKnownID objectClass="text" translateFrom="%Administrators%" translateTo="Administrateurs" />
		<wellKnownID objectClass="text" translateFrom="%DomainAdmins%" translateTo="Admins du domaine" />
		<wellKnownID objectClass="text" translateFrom="%SchemaAdmins%" translateTo="Administrateurs du schéma" />
		<wellKnownID objectClass="text" translateFrom="%EnterpriseAdmins%" translateTo="Administrateurs de l’entreprise" />
		<wellKnownID objectClass="text" translateFrom="%Users%" translateTo="Utilisateurs" />
		<wellKnownID objectClass="text" translateFrom="%Guest%" translateTo="Invité" />
		-->
		<!-- FR-FR - END   -->
		<wellKnownID objectClass="text" translateFrom="%NetBios%" translateTo="HARDEN" />
		<wellKnownID objectClass="text" translateFrom="%domaindns%" translateTo="HARDEN.AD" />
		<wellKnownID objectClass="text" translateFrom="%DN%" translateTo="DC=HARDEN,DC=AD" />
		<wellKnownID objectClass="text" translateFrom="%RootNetBios%" translateTo="HARDEN" />
		<wellKnownID objectClass="text" translateFrom="%domain%" translateTo="HARDEN" />
		<wellKnownID objectClass="text" translateFrom="%Rootdomaindns%" translateTo="HARDEN.AD" />
		<wellKnownID objectClass="text" translateFrom="%RootDN%" translateTo="DC=HARDEN,DC=AD" />
		<wellKnownID objectClass="text" translateFrom="%AuthenticatedUsers%" translateTo="Authenticated Users" />
		<wellKnownID objectClass="text" translateFrom="%DnsAdmins%" translateTo="DnsAdmins" />
		<wellKnownID objectClass="text" translateFrom="%RemoteDesktopUsers%" translateTo="Remote Desktop Users" />
		<wellKnownID objectClass="group" translateFrom="%isT0%" translateTo="T0" />
		<wellKnownID objectClass="group" translateFrom="%isT1%" translateTo="T1" />
		<wellKnownID objectClass="group" translateFrom="%isT2%" translateTo="T2" />
		<wellKnownID objectClass="group" translateFrom="%isT1leg%" translateTo="T1L" />
		<wellKnownID objectClass="group" translateFrom="%isT2Leg%" translateTo="T2L" />
		<wellKnownID objectClass="group" translateFrom="%t0-global%" translateTo="L-S-T0" />
		<wellKnownID objectClass="group" translateFrom="%t1-global%" translateTo="L-S-T1" />
		<wellKnownID objectClass="group" translateFrom="%t2-global%" translateTo="L-S-T2" />
		<wellKnownID objectClass="group" translateFrom="%t1l-global%" translateTo="L-S-T1L" />
		<wellKnownID objectClass="group" translateFrom="%t2l-global%" translateTo="L-S-T2L" />
		<wellKnownID objectClass="group" translateFrom="%t0-managers%" translateTo="G-S-T0_Managers" />
		<wellKnownID objectClass="group" translateFrom="%pawaccess-logon%" translateTo="L-S-T0_PawAccess_Logon" />
		<wellKnownID objectClass="group" translateFrom="%pawt0-logon%" translateTo="L-S-T0_PawT0_Logon" />
		<wellKnownID objectClass="group" translateFrom="%pawt12l-logon%" translateTo="L-S-T0_PawT12L_Logon" />
		<wellKnownID objectClass="group" translateFrom="%t0-localAdmin-servers%" translateTo="L-S-T0_LocalAdmins_Servers" />
		<wellKnownID objectClass="group" translateFrom="%t0-localAdmin-workstations%" translateTo="L-S-T0_LocalAdmins_Workstations" />
		<wellKnownID objectClass="group" translateFrom="%t1-managers%" translateTo="G-S-T1_Managers" />
		<wellKnownID objectClass="group" translateFrom="%t1-administrators%" translateTo="G-S-T1_Administrators" />
		<wellKnownID objectClass="group" translateFrom="%t1-operators%" translateTo="G-S-T1_Operators" />
		<wellKnownID objectClass="group" translateFrom="%t1-localAdmin-servers%" translateTo="L-S-T1_LocalAdmins_Servers" />
		<wellKnownID objectClass="group" translateFrom="%t2-managers%" translateTo="G-S-T2_Managers" />
		<wellKnownID objectClass="group" translateFrom="%t2-administrators%" translateTo="G-S-T2_Administrators" />
		<wellKnownID objectClass="group" translateFrom="%t2-operators%" translateTo="G-S-T2_Operators" />
		<wellKnownID objectClass="group" translateFrom="%t2-localAdmin-workstations%" translateTo="L-S-T2_LocalAdmins_Workstations" />
		<wellKnownID objectClass="group" translateFrom="%tll-operators%" translateTo="G-S-T1L_Operators" />
		<wellKnownID objectClass="group" translateFrom="%t2l-operators%" translateTo="G-S-T2L_Operators" />
		<wellKnownID objectClass="group" translateFrom="%t1l-localAdmin-servers%" translateTo="L-S-T1L_LocalAdmins_Servers" />
		<wellKnownID objectClass="group" translateFrom="%t2l-localAdmin-workstations%" translateTo="L-S-T2L_LocalAdmins_Workstations" />
		<wellKnownID objectClass="group" translateFrom="%T1-LAPS-PasswordReset%" translateTo="L-S-T1-DELEG_LAPS_PwdReset" />
		<wellKnownID objectClass="group" translateFrom="%T1-LAPS-PasswordReader%" translateTo="L-S-T1-DELEG_LAPS_PwdRead" />
		<wellKnownID objectClass="group" translateFrom="%T2-LAPS-PasswordReset%" translateTo="L-S-T2-DELEG_LAPS_PwdReset" />
		<wellKnownID objectClass="group" translateFrom="%T2-LAPS-PasswordReader%" translateTo="L-S-T2-DELEG_LAPS_PwdRead" />
		<wellKnownID objectClass="group" translateFrom="%T0-DLG-CptrDomJoin%" translateTo="L-S-T0-DELEG_Computer - Join Domain" />
		<wellKnownID objectClass="group" translateFrom="%T1-DLG-CptrDomJoin%" translateTo="L-S-T1-DELEG_Computer - Join Domain" />
		<wellKnownID objectClass="group" translateFrom="%T2-DLG-CptrDomJoin%" translateTo="L-S-T2-DELEG_Computer - Join Domain" />
		<wellKnownID objectClass="group" translateFrom="%Prefix%" translateTo="L-S" />
		<wellKnownID objectClass="group" translateFrom="%Prefix-domLoc%" translateTo="L-S-" />
		<wellKnownID objectClass="group" translateFrom="%Prefix-global%" translateTo="G-S-" />
		<wellKnownID objectClass="group" translateFrom="%Groups_Computers%" translateTo="LocalAdmins_%ComputerName%" />
		<wellKnownID objectClass="text" translateFrom="%OU-Adm%" translateTo="_Administration" />
		<wellKnownID objectClass="text" translateFrom="%OU-ADM-Groups-T0%" translateTo="GroupsT0" />
		<wellKnownID objectClass="text" translateFrom="%OU-ADM-Groups-T1%" translateTo="GroupsT1" />
		<wellKnownID objectClass="text" translateFrom="%OU-ADM-Groups-T2%" translateTo="GroupsT2" />
		<wellKnownID objectClass="text" translateFrom="%OU-ADM-Groups-T1L%" translateTo="GroupsT1L" />
		<wellKnownID objectClass="text" translateFrom="%OU-ADM-Groups-T2L%" translateTo="GroupsT2L" />
		<wellKnownID objectClass="text" translateFrom="%OU-PawAcs%" translateTo="PawAccess" />
		<wellKnownID objectClass="text" translateFrom="%OU-PAW-T0%" translateTo="PawT0" />
		<wellKnownID objectClass="text" translateFrom="%OU-PAW-T12L%" translateTo="PawT12L" />
		<wellKnownID objectClass="text" translateFrom="%OU-LocalAdmins%" translateTo="LocalAdmins" />
		<wellKnownID objectClass="text" translateFrom="%OU-Production-T0%" translateTo="Harden_T0" />
		<wellKnownID objectClass="text" translateFrom="%OU-Production-T12%" translateTo="Harden_T12" />
		<wellKnownID objectClass="text" translateFrom="%OU-PRD-T12-Workstations%" translateTo="Workstations" />
		<wellKnownID objectClass="text" translateFrom="%OU-PRD-T12-Servers%" translateTo="Servers" />
		<wellKnownID objectClass="text" translateFrom="%OU-Production-TL%" translateTo="Harden_TL" />
		<wellKnownID objectClass="param" translateFrom="%pwdLength%" translateTo="16" />
		<wellKnownID objectClass="param" translateFrom="%pwdNonAlphaNumChar%" translateTo="3" />
		<!-- 
			Keywords are used to shorten the GPO groups name.
		-->
		<Keyword LongName="serveurs" ShortenName="Srv" />
		<Keyword LongName="serveur" ShortenName="Srv" />
		<Keyword LongName="servers" ShortenName="Srv" />
		<Keyword LongName="server" ShortenName="Srv" />
		<Keyword LongName="workstations" ShortenName="Wks" />
		<Keyword LongName="workstation" ShortenName="Wks" />
		<Keyword LongName="services" ShortenName="Svc" />
		<Keyword LongName="service" ShortenName="Svc" />
		<Keyword LongName="Comptes" ShortenName="Cmpt" />
		<Keyword LongName="Compte" ShortenName="Cmpt" />
		<Keyword LongName="accounts" ShortenName="Acct" />
		<Keyword LongName="account" ShortenName="Acct" />
		<Keyword LongName="passwords" ShortenName="Pwd" />
		<Keyword LongName="password" ShortenName="Pwd" />
		<Keyword LongName="Firewalls" ShortenName="Fwl" />
		<Keyword LongName="Firewall" ShortenName="Fwl" />
		<Keyword LongName="sécurité" ShortenName="Secu" />
		<Keyword LongName="securité" ShortenName="Secu" />
		<Keyword LongName="security" ShortenName="Secu" />
		<Keyword LongName="local" ShortenName="Loc" />
		<Keyword LongName="administrators" ShortenName="Adm" />
		<Keyword LongName="administrator" ShortenName="Adm" />
		<Keyword LongName="Operators" ShortenName="Ope" />
		<Keyword LongName="Operator" ShortenName="Ope" />
		<Keyword LongName="Managers" ShortenName="Mgr" />
		<Keyword LongName="Manager" ShortenName="Mgr" />
	</Translation>
	<GroupPolicies>
		<WmiFilters>
			<!-- 
				The <WmiFilter> section allows the script to import MOF files to the Group Policy WMI Filters Container.
				Once a WMI Filter has been imported, it could be attached to a GPO through this script with te <GpoFilter> reference.
				All MOF files to import must be located in .\Inputs\GroupPolicies\WmiFilters.
				Name refers to the display name, as shown in the GUI. Source refers to the source mof file to import.
			-->
			<Filter Name="Windows-10" Source="Windows-10.mof" />
			<Filter Name="Windows-11" Source="Windows-11.mof" />
			<Filter Name="Windows-2000-XP" Source="Windows-2000-XP.mof" />
			<Filter Name="Windows-2003-2003R2-NoDC" Source="Windows-2003-2003R2-NoDC.mof" />
			<Filter Name="Windows-2008-Vista-and-Newer" Source="Windows-2008-Vista-and-Newer.mof" />
			<Filter Name="Windows-2008-NoDC" Source="Windows-2008-NoDC.mof" />
			<Filter Name="Windows-2008R2-NoDC" Source="Windows-2008R2-NoDC.mof" />
			<Filter Name="Windows-2012-NoDC" Source="Windows-2012-NoDC.mof" />
			<Filter Name="Windows-2012" Source="Windows-2012.mof" />
			<Filter Name="Windows-2012R2-NoDC" Source="Windows-2012R2-NoDC.mof" />
			<Filter Name="Windows-2012R2" Source="Windows-2012R2.mof" />
			<Filter Name="Windows-2016-and-Newer-NoDC" Source="Windows-2016-and-Newer-NoDC.mof" />
			<Filter Name="Windows-2016-and-Newer" Source="Windows-2016-and-Newer.mof" />
			<Filter Name="Windows-2016-NoDC" Source="Windows-2016-NoDC.mof" />
			<Filter Name="Windows-2016" Source="Windows-2016.mof" />
			<Filter Name="Windows-2019-NoDC" Source="Windows-2019-NoDC.mof" />
			<Filter Name="Windows-2019" Source="Windows-2019.mof" />
			<Filter Name="Windows-2022-NoDC" Source="Windows-2022-NoDC.mof" />
			<Filter Name="Windows-2022" Source="Windows-2022.mof" />
			<Filter Name="Windows-7" Source="Windows-7.mof" />
			<Filter Name="Windows-8" Source="Windows-8.mof" />
			<Filter Name="Windows-Legacy-NoDC" Source="Windows-Legacy-NoDC.mof" />
			<Filter Name="Windows-Legacy-OS-Clients" Source="Windows-Legacy-OS-Clients.mof" />
			<Filter Name="Windows-Legacy-OS-Servers-NoDC" Source="Windows-Legacy-OS-Servers-NoDC.mof" />
			<Filter Name="Windows-Legacy-OS-Servers" Source="Windows-Legacy-OS-Servers.mof" />
			<Filter Name="Windows-Legacy" Source="Windows-Legacy.mof" />
			<Filter Name="Windows-NoDC" Source="Windows-NoDC.mof" />
			<Filter Name="Windows-OS-Clients" Source="Windows-OS-Clients.mof" />
			<Filter Name="Windows-OS-Servers-NoDC" Source="Windows-OS-Servers-NoDC.mof" />
			<Filter Name="Windows-OS-Servers" Source="Windows-OS-Servers.mof" />
			<Filter Name="Windows-Supported-NoDC" Source="Windows-Supported-NoDC.mof" />
			<Filter Name="Windows-Supported-OS-Clients" Source="Windows-Supported-OS-Clients.mof" />
			<Filter Name="Windows-Supported-OS-Servers-NoDC" Source="Windows-Supported-OS-Servers-NoDC.mof" />
			<Filter Name="Windows-Supported-OS-Servers" Source="Windows-Supported-OS-Servers.mof" />
			<Filter Name="Windows-Supported" Source="Windows-Supported.mof" />
			<Filter Name="Windows-Vista" Source="Windows-Vista.mof" />
			<Filter Name="Windows-x64" Source="Windows-x64.mof" />
			<Filter Name="Windows-x64-NoDC" Source="Windows-x64-NoDC.mof" />
			<Filter Name="Windows-x86" Source="Windows-x86.mof" />
			<Filter Name="Windows-x86-NoDC" Source="Windows-x86-NoDC.mof" />
			<Filter Name="Windows-PDC" Source="Windows-PDC.mof" />
		</WmiFilters>
		<!--
			The <GPO> elements list the Group Policy added (or refreshed) to the target domain.
			Each of this Group Policy is first generated with no data (if not existing), then data is imported from its backup folder.
				> BackupID...: refer to the unique ID of the backup folder
				> validation.: if set to  No, the GPO is created and overwrited from its backup. Yes will only link the GPO to its targets.
				> Name.......: refer to the display name, as shown in the GUI
				> Description: description label, as shown in the GUI.

			The <GPOMODE> will identify the Tier perimeter (for group management) and mode to be applied.
		   		> Tier.......: Tier0, Tier1 or Tier2.
		   		> Mode.......: APPLY, DENY or BOTH. Apply create a group that limit the application scope, whereas DENY enforce the application
		        	          to everyone except the denied one. BOTH mix the two modes, enforcing application to only a scoped target group
		            	      with an exception scope (usefull for migration or testing purpose). If mode is ommited, the mode BOTH will be used.

			The <gpoDeny> ID attribute will set the specified identity with permission "Deny Execute" - you can se as many input as requiered.
				> ID......: use either sAMAccountName, object GUID or SID to identify the target identity to deny.

			The <gpoLink> attribute Will link the GPO to the specified target - you can use as many input as requiered.
				> Path....: DistinguishedName of the target OU where the GPO have to be linked. Use "RootDN" to refer to the DN of the domain.
				> Enabled.: "Yes", "No". Teach the script to enable the link or not.
				> Enforced: "Yes", "No". Teach the script to enforce this stratagy to any descending GPO that normally overcome its parameters.

			The <GpoFilter> parameter refers to the WMI filter that should be linked to this GPO.
				> WMI.....: the Display Name of the target WMI filter to be used (you can refer to the name section of the MOF import)
	
			The <GpoSecurityFilter> parameter tasks the script to set "authenticated users" as read only and add a security group as new security filter extension.
		
			GPO GROUP SETTINGS: used to generate APPLY and DENY Group Name. Use %tier% to mark the Tier localization in the new name
				> GpoName..: define the group name for applying or denying a group
		-->
		<GlobalGpoSettings GroupName="L-S-%tier%-GPO_%GpoName%_%mode%" Tier0="T0" Tier1="T1" Tier2="T2">
			<GpoTier0 OU="OU=GPO,OU=%OU-ADM-GROUPS-T0%,OU=%OU-ADM%,%DN%" />
			<GpoTier1 OU="OU=GPO,OU=%OU-ADM-GROUPS-T1%,OU=%OU-ADM%,%DN%" />
			<GpoTier2 OU="OU=GPO,OU=%OU-ADM-GROUPS-T2%,OU=%OU-ADM%,%DN%" />
		</GlobalGpoSettings>
		<!-- 
			WINDOWS UPDATE 
		-->
		<GPO BackupID="{3B8C8687-8779-4042-AFF9-83F88BB4B894}" Validation="Yes" Name="HAD-Auto-Update-S1-Thu-0h-Srv" Description="--- Harden AD --- &quot; ,&quot; Scheduling of updates and reboot after 15min of the machine in W1 on Wednesday at 00:00 AM">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Servers" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{89B9E68A-F486-4FA3-B336-7B10B22E714A}" Validation="Yes" Name="HAD-Auto-Update-S1-Thu-1h-Srv" Description="--- Harden AD --- &quot; ,&quot; Scheduling of updates and reboot after 15min of the machine in W1 on Wednesday at 01:00 AM">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Servers" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{7B81D2FF-C69F-4B0C-A91F-DAF6D953555E}" Validation="Yes" Name="HAD-Auto-Update-S3-Thu-0h-Srv" Description="--- Harden AD --- &quot; ,&quot; Scheduling of updates and reboot after 15min of the machine in W3 on Wednesday at 00:00 AM">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Servers" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{A89FC9A2-EB8E-4E4D-8031-80BF04F5A992}" Validation="Yes" Name="HAD-Auto-Update-S3-Thu-1h-Srv" Description="--- Harden AD --- &quot; ,&quot; Scheduling of updates and reboot after 15min of the machine in W3 on Wednesday at 01:00 AM">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Servers" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{5B6FA350-D2C7-4A62-A107-3C59017EBAAC}" Validation="Yes" Name="HAD-Auto-Update-S4-Thu-0h-Srv" Description="--- Harden AD --- &quot; ,&quot; Scheduling of updates and reboot after 15min of the machine in W4 on Wednesday at 00:00 AM">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Servers" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{69D0F16E-B88F-4965-8B1D-1AB6CD1B7C7A}" Validation="Yes" Name="HAD-Auto-Update-S4-Thu-1h-Srv" Description="--- Harden AD --- &quot; ,&quot; Scheduling of updates and reboot after 15min of the machine in W4 on Wednesday at 01:00 AM">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Servers" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{22589A7C-8042-48FD-95F5-64673EE4BAAA}" Validation="Yes" Name="HAD-Auto-Update-Win10-11" Description="--- Harden AD --- &quot; ,&quot; Setting up Windows Update on Windows 10/11 machines according to the recommendations">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Clients" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{3BE6078C-5B36-4C4A-80BB-C619EA5C98B3}" Validation="Yes" Name="HAD-Auto-Update-Win7-8" Description="--- Harden AD --- &quot; ,&quot; Setting up Windows Update on Windows 7/8 machines according to the recommendations">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Legacy-OS-Clients" />
			<GpoLink Path="OU=Harden_TL,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!--
			BITLOCKER
		-->
		<GPO BackupID="{DD870AA3-5A5D-4C72-A602-C9AC78ED7B32}" Validation="Yes" Name="HAD-BitLocker-TPMOnly-Enabled-Win10-11" Description="--- Harden AD --- &quot; ,&quot; Enable BitLocker encryption with Trusted Platform Module.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Clients" />
			<GpoLink Path="OU=Workstations,OU=Harden_T0,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Workstations,OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{640E7540-7FCF-4B44-926C-CF38E885EDE1}" Validation="Yes" Name="HAD-BitLocker-PIN-Enabled-Win10-11" Description="--- Harden AD --- &quot; ,&quot; Enable BitLocker encryption with Trusted Platform Module. 6-digit PIN code required.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Clients" />
			<GpoLink Path="OU=Workstations,OU=Harden_T0,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Workstations,OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{D71ADCFE-2648-481E-8CFC-936389800BBE}" Validation="Yes" Name="HAD-BitLocker-USB-Win10-11" Description="--- Harden AD --- &quot; ,&quot; Enable BitLocker encryption for USB drives with a password.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Clients" />
			<GpoLink Path="OU=Workstations,OU=Harden_T0,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Workstations,OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!--
			BLOODHOUND 
		-->
		<GPO BackupID="{651CC04C-B863-4346-B90F-7D97B42020BC}" Validation="Yes" Name="HAD-BloodHound-Mitigation" Description="--- Harden AD --- &quot; ,&quot; Disable Net Session enumeration - Bloodhound / NetCease.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			BLOCK WEBCAM ON LOCK 
		-->
		<GPO BackupID="{4AA1D324-A28C-4E3D-A356-A9992E1ED1F4}" Validation="Yes" Name="HAD-Camera-on-lockon-Disabled" Description="--- Harden AD --- &quot; ,&quot; Blocks the camera on the lock screen.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Clients" />
		</GPO>
		<!-- 
			LEGACY: BLOCK DC LOCATOR REGISTRATION 
		-->
		<GPO BackupID="{43B72F81-55EE-4E7E-890B-7B738677B14A}" Validation="Yes" Name="HAD-DCLocaltor-Configuration" Description="--- Harden AD --- &quot; ,&quot; Prevents the DC from generating its DNS entries in -tcp-msdsc.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
		</GPO>
		<!-- 
			LEGACY: DISABLING DANGEROUS SERVICES 
		-->
		<GPO BackupID="{F9DBA31A-45A6-42A2-B63C-4ED76AC5DB58}" Validation="Yes" Name="HAD-DistributedFileSystem-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disable the Windows DFS Namespace service.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Legacy-OS-Servers" />
			<GpoLink Path="OU=Harden_TL,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			FIPS 
		-->
		<GPO BackupID="{5B274948-774F-4604-96AD-45D2CFDA0015}" Validation="Yes" Name="HAD-FIPS-Enabled" Description="--- Harden AD --- &quot; ,&quot; Forces the use of the FIPS algorithm where possible.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			MS FIREWALL 
		-->
		<GPO BackupID="{33E571EF-52D9-48BF-9A42-BB2C7ACECD5B}" Validation="Yes" Name="HAD-Firewall-Audit-Only" Description="--- Harden AD --- &quot; ,&quot; Setup Microsoft Firewall in audit mode (allow all, log everything).">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{FE6AD3D8-4733-4C25-9006-BB2B2402FD07}" Validation="Yes" Name="HAD-Firewall-Block-Inbound" Description="--- Harden AD --- &quot; ,&quot; Setup Microsoft Firewall in active mode in addition to system local rules.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			GPO PROCESSUS 
		-->
		<GPO BackupID="{B2FC1442-08FD-4CDE-AF82-417E0CE1046F}" Validation="Yes" Name="HAD-GPO-Refresh-Cycle" Description="--- Harden AD --- &quot; ,&quot; Set the GPO refresh rate to 15 minutes.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!--
			IP PROTOCOL 
		-->
		<GPO BackupID="{4C100949-4368-407F-B371-A80615D07305}" Validation="Yes" Name="HAD-IPv6-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disables IPv6.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			KERBEROS 
		-->
		<GPO BackupID="{960547AE-574B-4A5E-B238-7A6C0DD491D2}" Validation="Yes" Name="HAD-Kerberos-AES-Enabled" Description="--- Harden AD --- &quot; ,&quot; Set the encryption types that Kerberos is allowed to use.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			LAPS 
		-->
		<GPO BackupID="{614C4CD2-6F10-416C-90C4-BB1AB8703FA1}" Validation="Yes" Name="HAD-LAPS-Configuration" Description="--- Harden AD --- &quot; ,&quot; Configuration of the LAPS utility.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-NoDC" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{6D104481-B9FC-4ABD-ACD0-CAB7BE59833E}" Validation="Yes" Name="HAD-LAPS-X64-Deployment" Description="--- Harden AD --- &quot; ,&quot; Deployment of the LAPS utility for 64bit systems.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-x64-NoDC" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{BAC83533-881C-427B-BDB8-A70526A84ADD}" Validation="Yes" Name="HAD-LAPS-X86-Deployment" Description="--- Harden AD --- &quot; ,&quot; Deployment of the LAPS utility for 32bit systems.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-x86-NoDC" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			LDAP PROTOCOL 
		-->
		<GPO BackupID="{FA2ECE42-130C-4E79-A30A-CF4B5567C5FA}" Validation="Yes" Name="HAD-LDAP-Audit-Enabled" Description="--- Harden AD --- &quot; ,&quot; Enable event logs for the LDAP protocol.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=Domain Controllers,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{CA093B03-5505-4704-B673-EA94ED4F8994}" Validation="Yes" Name="HAD-LDAP-CBT-Enabled" Description="--- Harden AD --- &quot; ,&quot; Enforces validation of Channel Binding Tokens (CBT) received in LDAP bind requests.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{26CD251A-3354-44D5-94E4-30D0B854A3F3}" Validation="Yes" Name="HAD-LDAP-Client-Signing-Not-Required" Description="--- Harden AD --- &quot; ,&quot; Does not require a signature for LDAP communications with a client.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{47A91C4D-D50A-4C35-9AE3-DFF1DB8299E4}" Validation="Yes" Name="HAD-LDAP-Client-Signing-Required" Description="--- Harden AD --- &quot; ,&quot; Requires signing for LDAP communications with a client.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{DA84E960-529F-4580-A16A-E8C73CCE27F0}" Validation="Yes" Name="HAD-LDAP-Server-Signing-Required" Description="--- Harden AD --- &quot; ,&quot; Requires signing for LDAP communications with a server.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{37624146-725D-4C9D-812A-64980DEA40B4}" Validation="Yes" Name="HAD-LDAP-Audit-Disabled" Description="--- Harden AD --- &quot; ,&quot; Configure default search provider.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
		</GPO>
		<!-- 
			LLMNR 
		-->
		<GPO BackupID="{5FCEADFE-DFF0-40E7-BDA1-D49DC3EB5655}" Validation="Yes" Name="HAD-LLMNR-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disables Link-local Multicast Name Resolution (LLMNR).">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			LAN MANAGER AND NT LAN MANAGER
		-->
		<GPO BackupID="{E26B2FB8-9251-45D2-99ED-0B643A0759DB}" Validation="Yes" Name="HAD-LMHASH-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disables LMHASH.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{4753AF43-1FD0-4A59-A442-B79EE4E9A290}" Validation="Yes" Name="HAD-NTLM-Audit-Enabled" Description="--- Harden AD --- &quot; ,&quot; Enable NTLM audit on Domain Controller.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=Domain Controllers,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{5B9C9897-9806-4996-A3E6-10403FD271ED}" Validation="Yes" Name="HAD-NTLM1-LMx-Disabled" Description="--- Harden AD --- &quot; ,&quot; Forces the use of NTLMv2 response. LM and NTLMv1 responses are refused.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{BFB24A1C-121B-400E-86C2-CD43AD6FFA54}" Validation="Yes" Name="HAD-NTLMv2-128bits-Required" Description="--- Harden AD --- &quot; ,&quot; Configure NTLMv2 to use 128-bit encryption.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			LOCAL ADMINISTRATORS 
		-->
		<GPO BackupID="{0CC9CFC9-29C0-49DE-B23E-6C103028AC7A}" Validation="Yes" Name="HAD-LocalAdmins-Paw" Description="--- Harden AD --- &quot; ,&quot; Add the local administration AD group to the corresponding PAW's integrated administrator group">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=PawAccess,OU=_Administration,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{ACFA486C-3622-43DC-8554-5702351A7EF6}" Validation="Yes" Name="HAD-LocalAdmins-PawT0" Description="--- Harden AD --- &quot; ,&quot; Add the local administration AD group to the corresponding T0 PAW's integrated administrator group">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=PawT0,OU=_Administration,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{43E44692-0CCF-412B-97A0-CFBDD4F4B2DA}" Validation="Yes" Name="HAD-LocalAdmins-PawT12L" Description="--- Harden AD --- &quot; ,&quot; Add the local administration AD group to the corresponding T12L PAW's integrated administrator group">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=PawT12L,OU=_Administration,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{B9A42D3A-61F4-45D4-BF94-D61B80570838}" Validation="Yes" Name="HAD-LocalAdmins-T0-Srv" Description="--- Harden AD --- &quot; ,&quot; Add the local administration AD group to the corresponding T0 system's integrated administrator group">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Servers-NoDC" />
			<GpoLink Path="OU=Harden_T0,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{F9EF6561-3ED3-4990-AB9B-E53CCC855B94}" Validation="Yes" Name="HAD-LocalAdmins-T0-Wks" Description="--- Harden AD --- &quot; ,&quot; Add the local administration AD group to the corresponding T0 system's integrated administrator group">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Clients" />
			<GpoLink Path="OU=Harden_T0,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{9B52CEFC-64E9-43EF-A822-DA5557416251}" Validation="Yes" Name="HAD-LocalAdmins-T1" Description="--- Harden AD --- &quot; ,&quot; Add the local administration AD group to the corresponding T1 system's integrated administrator group">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Servers-NoDC" />
			<GpoLink Path="OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Computers,OU=Provisioning,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{BFB98271-72B9-4791-BBFC-E76513A86AB8}" Validation="Yes" Name="HAD-LocalAdmins-T1L" Description="--- Harden AD --- &quot; ,&quot; Add the local administration AD group to the corresponding legacy server (T1L) system's integrated administrator group">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Legacy-OS-Servers-NoDC" />
			<GpoLink Path="OU=Harden_TL,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{DBB5A54A-4338-4D59-A25E-BD71CEBB86B2}" Validation="Yes" Name="HAD-LocalAdmins-T2" Description="--- Harden AD --- &quot; ,&quot; Add the local administration AD group to the corresponding T2 system's integrated administrator group">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Clients" />
			<GpoLink Path="OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Computers,OU=Provisioning,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{F1824E32-8FAF-4203-8799-BCD9FEE8681A}" Validation="Yes" Name="HAD-LocalAdmins-T2L" Description="--- Harden AD --- &quot; ,&quot; Add the local administration AD group to the corresponding legacy workstation (T2L) system's integrated administrator group">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Legacy-OS-Clients" />
			<GpoLink Path="OU=Harden_TL,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			LOCAL ACCOUNTS SETUP 
		-->
		<GPO BackupID="{4D5DF38A-161D-42AD-A29B-94309EDE3D0D}" Validation="Yes" Name="HAD-Local-Accounts-Config" Description="--- Harden AD --- &quot; ,&quot; Enable and rename the local administrator account. Disable and rename the local guest account.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=_Administration,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Harden_T0,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Harden_TL,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Computers,OU=Provisioning,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			LOGIN RESTRICTION 
		-->
		<GPO BackupID="{BB58C8C0-81A4-403E-99ED-E18F0C577632}" Validation="Yes" Name="HAD-LoginRestrictions-Paw" Description="--- Harden AD --- &quot; ,&quot; Restrict connections to administration stations">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=PawAccess,OU=_Administration,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{6405F191-E007-4CC5-A05D-14EE8FC2F1C5}" Validation="Yes" Name="HAD-LoginRestrictions-PawT0" Description="--- Harden AD --- &quot; ,&quot; Restrict connections to tier 0 administration stations">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=PawT0,OU=_Administration,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{CA0E80E7-B301-4BB9-A17C-B83BB21CD096}" Validation="Yes" Name="HAD-LoginRestrictions-PawT12L" Description="--- Harden AD --- &quot; ,&quot; Restrict connections to legacy administration stations">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=PawT12L,OU=_Administration,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{7F2DE5D7-B30E-4F9D-BA75-BCD4990C090D}" Validation="Yes" Name="HAD-LoginRestrictions-T0" Description="--- Harden AD --- &quot; ,&quot; Blocks connections to tier 0 machines from other tier accounts">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=Harden_T0,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{5AA1BA07-A0C5-4DB2-8691-86D935F78A95}" Validation="Yes" Name="HAD-LoginRestrictions-T1" Description="--- Harden AD --- &quot; ,&quot; Blocks connections to tier 1 machines from other tier accounts">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Servers-NoDC" />
			<GpoLink Path="OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{DF3FCFB1-7A84-496D-89F7-E20650345108}" Validation="Yes" Name="HAD-LoginRestrictions-T1L" Description="--- Harden AD --- &quot; ,&quot; Blocks connections to tier legacy servers from other tier accounts">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Legacy-OS-Servers-NoDC" />
			<GpoLink Path="OU=Harden_TL,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{16A30E61-AD85-407B-BDFF-8C447FDB3C48}" Validation="Yes" Name="HAD-LoginRestrictions-T2" Description="--- Harden AD --- &quot; ,&quot; Blocks connections to tier 2 machines from other tier accounts">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Clients" />
			<GpoLink Path="OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{79829C3F-96B4-475F-844D-CE2FFBD467AB}" Validation="Yes" Name="HAD-LoginRestrictions-T2L" Description="--- Harden AD --- &quot; ,&quot; Blocks connections to tier legacy workstations from other tier accounts">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Legacy-OS-Clients" />
			<GpoLink Path="OU=Harden_TL,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			LOGON CACHE 
		-->
		<GPO BackupID="{38C8D47E-E4F2-4DF2-8B60-BE9B3E53647D}" Validation="Yes" Name="HAD-Logon-Cache-0" Description="--- Harden AD --- &quot; ,&quot; No login credentials cached from servers.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Servers" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{BC9F44A0-7603-4223-AD48-9467B675086F}" Validation="Yes" Name="HAD-Logon-Cache-2" Description="--- Harden AD --- &quot; ,&quot; Keeps two login credentials cached from servers.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Clients" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			OS HARDENING 
		-->
		<GPO BackupID="{41D3950E-ACD2-4CD8-99B5-DE791765C727}" Validation="Yes" Name="HAD-MSLive-Accounts-Disabled" Description="--- Harden AD --- &quot; ,&quot; Blocks the use of personal Microsoft accounts.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{CBC80F59-C833-4D33-AC3A-4AA9F96822EB}" Validation="Yes" Name="HAD-NBT-NS-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disables DNS Fallback functionality: NBT-NS.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{0B5A54A5-92DB-4405-AE69-CB2154F4E613}" Validation="Yes" Name="HAD-PageFile-Shutdown-Cleared" Description="--- Harden AD --- &quot; ,&quot; Empty the pagefile.sys on each shutdown.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{993763F7-7500-4F90-89F7-52EF29307A2E}" Validation="Yes" Name="HAD-Print-Spooler-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disables the print spooler service on windows system.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Servers" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{A10BD6F3-E157-46B1-AA07-D3ED1BC764BD}" Validation="Yes" Name="HAD-Remote-Assistance-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disable Windows remote assistance.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-OS-Clients" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{393E2FCB-5EDC-4E30-B82C-2B125193B550}" Validation="Yes" Name="HAD-Screenlock-Enabled" Description="--- Harden AD --- &quot; ,&quot; Lock inactive sessions after 20 minutes.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{6D9CD91B-F046-41C4-8BC1-4001459D3890}" Validation="Yes" Name="HAD-Secure-NetLogon" Description="--- Harden AD --- &quot; ,&quot; Secure Netlogon service.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{6697D7EB-62A0-4474-A4FE-5376411CE853}" Validation="Yes" Name="HAD-Svc-Browser-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disable the Windows Browser service.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Legacy-NoDC" />
			<GpoLink Path="OU=Harden_TL,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{0D7EC07C-0235-4A6D-AD9A-2DC9CB4ECC38}" Validation="Yes" Name="HAD-Svc-Server-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disables Lanman Server Service.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Legacy-NoDC" />
			<GpoLink Path="OU=Harden_TL,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{E8BF7E49-1AB8-430E-A215-E36E83FFD59F}" Validation="Yes" Name="HAD-UAC-Enabled" Description="--- Harden AD --- &quot; ,&quot; Enables UAC's approval mode for all administrators.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{C1E0AA24-E741-429C-A7C6-DE7577079C87}" Validation="Yes" Name="HAD-WDigest-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disables WDigest protocol.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{5E8614C4-055C-48F4-B2DB-639997ECAE42}" Validation="Yes" Name="HAD-Windows-Defender-Config" Description="--- Harden AD --- &quot; ,&quot; Configures Windows Defender.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{AA0F3BCB-8435-4A58-A8F4-5D631039B623}" Validation="Yes" Name="HAD-WinRM-Basic-Digest-Auth-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disallows basic, unencrypted authentication for WinRM use.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{C79D8C30-10FD-4C5E-A2EE-5CFE50A0DA3D}" Validation="Yes" Name="HAD-WebProxyAutoDiscovery-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disable Web Proxy Auto-Discovery Protocol.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			GENERAL LOGS AND AUDIT 
		-->
		<GPO BackupID="{9BC7A0A1-5911-4505-8800-A5A12C837301}" Validation="Yes" Name="HAD-PowerShell-Logs" Description="--- Harden AD --- &quot; ,&quot; Enable Logs for PowerShell.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-2008-Vista-and-Newer" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{57559440-1A69-4B88-954D-67CFBDAC90B1}" Validation="Yes" Name="HAD-Security-Logs" Description="--- Harden AD --- &quot; ,&quot; Configures security logs based on ANSSI recommendations.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			DC SCHEDULED TASKS 
		-->
		<GPO BackupID="{60C4FFE1-F082-49EE-9AF2-F7ABA228D05F}" Validation="Yes" Name="HAD-TS-Local-admins-groups" Description="--- Harden AD --- &quot; ,&quot; Import the HADLocalAdmins module and create the associated scheduled task.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=Domain Controllers,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{A8C72199-7FB0-4234-A737-4E5843814F1E}" Validation="Yes" Name="HAD-TS-PDC-Flush-admin-groups" Description="--- Harden AD --- &quot; ,&quot; Import the Group flushing script and create the associated scheduled task.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-PDC" />
			<GpoLink Path="OU=Domain Controllers,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{1767DE3C-3F23-4357-94F9-D252D2BC462C}" Validation="Yes" Name="HAD-TS-Reset-Computer-Sddl" Description="--- Harden AD --- &quot; ,&quot; Reset the sddl and owner of new computer objects through a schedule task.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=Domain Controllers,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			SECURE RDP 
		-->
		<GPO BackupID="{3A10AD30-D95C-42C4-AD45-C7E4CBFC2F2D}" Validation="Yes" Name="HAD-RDP-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disables the RDP service and prohibits RDP connections">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=Harden_TL,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{1BB7DBE3-5BDB-4959-AC11-5577497A0207}" Validation="Yes" Name="HAD-RDP-Enabled" Description="--- Harden AD --- &quot; ,&quot; Enable the RDP service, set the firewall and allow RDP connections">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Servers" />
			<GpoLink Path="OU=_Administration,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Harden_T0,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Computers,OU=Provisioning,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{6C86197E-8498-4E48-835B-054F00CA1EA3}" Validation="Yes" Name="HAD-RDP-NLA-Enabled" Description="--- Harden AD --- &quot; ,&quot; Enable NLA for RDP connections.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-Supported-OS-Servers" />
			<GpoLink Path="OU=_Administration,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Harden_T0,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
			<GpoLink Path="OU=Computers,OU=Provisioning,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			SMART CARD LOGIN 
		-->
		<GPO BackupID="{25F951CC-245B-4CB6-8138-F9F38CD3CB78}" Validation="Yes" Name="HAD-Smart-Card-Required" Description="--- Harden AD --- &quot; ,&quot; Force the use of Windows Hello for smartcards.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
		</GPO>
		<!-- 
			SMB HARDENING 
		-->
		<GPO BackupID="{6930963C-6F98-4496-93B9-09511AF49681}" Validation="Yes" Name="HAD-SMB-Signing-Configuration" Description="--- Harden AD --- &quot; ,&quot; Configure SMB signing for clients.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{AC97557E-E12C-48F3-AB4C-F1C41D4E3603}" Validation="Yes" Name="HAD-SMB1-Audit-Enabled" Description="--- Harden AD --- &quot; ,&quot; Creates a scheduled task to audit SMBv1.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-2008-Vista-and-Newer" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{AACD614B-7C19-4C6A-99AA-0CD91BADEC0E}" Validation="Yes" Name="HAD-SMB1-Client-Only-Enabled" Description="--- Harden AD --- &quot; ,&quot; Enables SMBv1 only for clients.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{78001DDD-6357-4EAA-A645-1311F6E59411}" Validation="Yes" Name="HAD-SMB1-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disables SMBv1.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-2008-Vista-and-Newer" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{D552CA4B-C9E9-455A-9821-924E890676C0}" Validation="Yes" Name="HAD-SMB1-Enabled" Description="--- Harden AD --- &quot; ,&quot; Enables SMBv1.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{0532EF52-A725-4E26-9A8C-45C3E2E07324}" Validation="Yes" Name="HAD-SMB1-Server-Only-Enabled" Description="--- Harden AD --- &quot; ,&quot; Enables SMBv1 only for servers.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{2D9C0297-0579-46AB-89FC-91F3297B190B}" Validation="Yes" Name="HAD-UNC-Hardened-Path" Description="--- Harden AD --- &quot; ,&quot; Enables SMBv1 only for servers.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=Domain Controllers,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<!-- 
			TLS AND SSL HARDENING 
		-->
		<GPO BackupID="{181A6227-DC22-4E7C-8EAE-DAC9DC2F43AD}" Validation="Yes" Name="HAD-SSL2-SSL3-Disabled" Description="--- Harden AD --- &quot; ,&quot; Disables SSLv2 and SSLv3 on Windows systems.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{1FB916B9-F453-4342-8636-1523DC68F698}" Validation="Yes" Name="HAD-SSL2-SSL3-Enabled" Description="--- Harden AD --- &quot; ,&quot; Enables SSLv2 and SSLv3 on Windows systems.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
		<GPO BackupID="{5C8FC2E1-4D88-4DE1-ABAC-EADDFAB774EC}" Validation="Yes" Name="HAD-TLS-1_0-Disabled" Description="--- Harden AD --- &quot; ,&quot; Configure default search provider.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
		</GPO>
		<GPO BackupID="{A3A7B599-37C0-484F-9560-8ED89D0B4C16}" Validation="Yes" Name="HAD-TLS-1_0-Enabled" Description="--- Harden AD --- &quot; ,&quot; Configure default search provider.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
		</GPO>
		<GPO BackupID="{E00C5E60-64BD-43AD-840F-CB1AFC59E264}" Validation="Yes" Name="HAD-TLS-1_1-Disabled" Description="--- Harden AD --- &quot; ,&quot; Configure default search provider.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
		</GPO>
		<GPO BackupID="{AFD12E92-B9D1-4139-9C5A-E8BD5C5B71A8}" Validation="Yes" Name="HAD-TLS-1_1-Enabled" Description="--- Harden AD --- &quot; ,&quot; Configure default search provider.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
		</GPO>
		<GPO BackupID="{DC5E5873-959B-422A-9FC5-2D88576ED9AB}" Validation="Yes" Name="HAD-TLS-1_2-Disabled" Description="--- Harden AD --- &quot; ,&quot; Configure default search provider.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
		</GPO>
		<GPO BackupID="{CBEE8835-3DB2-42E7-9497-9C1B70710342}" Validation="Yes" Name="HAD-TLS-1_2-Enabled" Description="--- Harden AD --- &quot; ,&quot; Configure default search provider.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
		</GPO>
		<!--
			DOMAIN JOIN
		-->
		<GPO BackupID="{3B6DC475-6822-49C1-B47A-4199DF4FE1E6}" Validation="Yes" Name="HAD-DC-Allow-Computer-Account-ReUse" Description="--- Harden AD --- &quot; ,&quot; Allow computer domain join to specific delegation group.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoLink Path="OU=Domain Controllers,RootDN" Enabled="Yes" Enforced="No" />
		</GPO>
		<!-- 
			SUPPPORT THE COMUNITY: USE QWANT! 
		-->
		<GPO BackupID="{B25D0E6D-70B8-40E4-B1D0-78F6FE9CF76F}" Validation="Yes" Name="HAD-QwantSearch" Description="--- Harden AD --- &quot; ,&quot; Configure default search provider.">
			<GpoMode Mode="BOTH" Tier="Tier0" />
			<GpoFilter WMI="Windows-x64-NoDC" />
			<GpoLink Path="OU=Workstations,OU=Harden_T12,RootDN" Enabled="Yes" Enforced="Yes" />
		</GPO>
	</GroupPolicies>
	<Accounts>
		<!--
			The <Account> Section list all user identities to be generated by the script.                                                       
			The script first check if the account is already present in the domain (if so, nothing is done), and if not, it will generatae it.  
			The newly created user is then stored with its random password in a keepass file (.\Outputs\HardenAD.kbdx).                         
			Each account is provided with the following input:                                                                                  
				> GivenName.....: the given name of the account                                                                                   
				> Surname.......: the surname of the account                                                                                      
				> sAMAccountName: the sAMAccountName of the account                                                                               
				> displayName...: the name displayed by the GUI                                                                                   
				> Description...: the description of the account                                                                                  
				> Path..........: the distingsuihedName of the OU containing the account. you can use ROOTDN to refer to the domain DN            
		-->
		<!-- 
			Tier 0 accounts - Manager 
		-->
		<User DisplayName="Admin Harden (T0M)" Surname="HARDEN" samAccountName="T0M-AHARDEN" GivenName="Admin" Description="Admin Harden (Tier 0 Manager)" Path="OU=UsersT0,OU=_Administration,ROOTDN" />
		<!-- 
			Tier 0 accounts - Operators 
		-->
		<User DisplayName="Admin Harden (T0O)" Surname="HARDEN" samAccountName="T0O-AHARDEN" GivenName="Admin" Description="Admin Harden (Tier 0 Operators)" Path="OU=UsersT0,OU=_Administration,ROOTDN" />
		<!--  
			Tier 1 accounts - Managers  
		-->
		<User DisplayName="Admin Harden (T1M)" Surname="HARDEN" samAccountName="T1M-AHARDEN" GivenName="Admin" Description="Admin Harden (Tier 1 Manager)" Path="OU=UsersT1,OU=_Administration,ROOTDN" />
		<!--  
			Tier 1 accounts - Administrators  
		-->
		<User DisplayName="Admin Harden (T1A)" Surname="HARDEN" samAccountName="T1A-AHARDEN" GivenName="Admin" Description="Admin HARDEN (Tier 1 Administrator)" Path="OU=UsersT1,OU=_Administration,ROOTDN" />
		<!--  
			Tier 1 accounts - Operators  
		-->
		<User DisplayName="Admin HARDEN (T1O)" Surname="HARDEN" samAccountName="T1O-AHARDEN" GivenName="Admin" Description="Admin HARDEN (Tier 1 Operator)" Path="OU=UsersT1,OU=_Administration,ROOTDN" />
		<!--  
			Tier 2 accounts - Managers  
		-->
		<User DisplayName="Admin HARDEN (T2M)" Surname="HARDEN" samAccountName="T2M-AHARDEN" GivenName="Admin" Description="Admin HARDEN (Tier 2 Manager)" Path="OU=UsersT2,OU=_Administration,ROOTDN" />
		<!-- 
			Tier 2 accounts - Administrators  
		-->
		<User DisplayName="Admin HARDEN (T2A)" Surname="HARDEN" samAccountName="T2A-AHARDEN" GivenName="Admin" Description="Admin HARDEN (Tier 2 Adminstrator)" Path="OU=UsersT2,OU=_Administration,ROOTDN" />
		<!--  
			Tier 2 accounts - Operators  
		-->
		<User DisplayName="Admin HARDEN (T2O)" Surname="HARDEN" samAccountName="T2O-AHARDEN" GivenName="Admin" Description="Admin HARDEN (Tier 2 Operator)" Path="OU=UsersT2,OU=_Administration,ROOTDN" />
		<!--  
			Tier 1 Legacy accounts - Operators  
		-->
		<User DisplayName="Admin HARDEN (T1LO)" Surname="HARDEN" samAccountName="T1LO-AHARDEN" GivenName="Admin" Description="Admin HARDEN (Tier 1 Legacy Operator)" Path="OU=UsersT1L,OU=_Administration,ROOTDN" />
		<!--  
			Tier 2 Legacy accounts - Operators  
		-->
		<User DisplayName="Admin HARDEN (T2LO)" Surname="HARDEN" samAccountName="T2LO-AHARDEN" GivenName="Admin" Description="Admin HARDEN (Tier 2 Legacy Operator)" Path="OU=UsersT2L,OU=_Administration,ROOTDN" />
	</Accounts>
	<Groups>
		<!-- 
			The <Groups> Section list all group identities to be generated by the script.
			The script first check if the group is already present in the domain (if so, nothing is done), and if not, it will generatae it.
			Each group is provided with the following input:
				> Name..........: the name of the group, also its display name and sAMAccountName
				> Description...: the description of the group
				> Scope.........: domainLocal, Local, Global or Universal
				> Category......: security or distribution

			In a second time, all groups are populated with the <member> input.
				> sAMAccountName: the sAMAccountName of the target member.
		-->
		<!--
			Profile groups
		-->
		<Group name="G-S-T0_Managers" Category="Security" Scope="Global" Description="Members of this group can see and manage all the Active Directory objects" Path="OU=GroupsT0,OU=_Administration,ROOTDN">
			<Member samAccountName="T0M-AHARDEN" />
		</Group>
		<Group name="G-S-T0_Operators" Category="Security" Scope="Global" Description="Members of this group can operate on Tier 0 resources" Path="OU=GroupsT0,OU=_Administration,ROOTDN">
			<Member samAccountName="T0O-AHARDEN" />
		</Group>
		<Group name="G-S-T1_Managers" Category="Security" Scope="Global" Description="Members of this group can manage all Tier 1 ressources, including T1 admin users and groups" Path="OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="T1M-AHARDEN" />
		</Group>
		<Group name="G-S-T1_Administrators" Category="Security" Scope="Global" Description="Members of this group can manage all Tier 1 resources, excluding T1 admin users and groups" Path="OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="T1A-AHARDEN" />
		</Group>
		<Group name="G-S-T1_Operators" Category="Security" Scope="Global" Description="Members of this group can operate on Tier 1 resources (login)" Path="OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="T1O-AHARDEN" />
		</Group>
		<Group name="G-S-T2_Managers" Category="Security" Scope="Global" Description="Members of this group can manage all Tier 2 ressources, including T1 admin users and groups" Path="OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="T2M-AHARDEN" />
		</Group>
		<Group name="G-S-T2_Administrators" Category="Security" Scope="Global" Description="Members of this group can manage all Tier 2 ressources, excluding T1 admin users and groups" Path="OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="T2A-AHARDEN" />
		</Group>
		<Group name="G-S-T2_Operators" Category="Security" Scope="Global" Description="Members of this group can operate on Tier 2 resources (login)" Path="OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="T2O-AHARDEN" />
		</Group>
		<Group name="G-S-T1L_Operators" Category="Security" Scope="Global" Description="Members of this group can operate on Tier Legacy server resources (login)" Path="OU=GroupsT1L,OU=_Administration,ROOTDN">
			<Member samAccountName="T1LO-AHARDEN" />
		</Group>
		<Group name="G-S-T2L_Operators" Category="Security" Scope="Global" Description="Members of this group can operate on Tier Legacy resources (login)" Path="OU=GroupsT2L,OU=_Administration,ROOTDN">
			<Member samAccountName="T2LO-AHARDEN" />
		</Group>
		<!--
			Tier Filtering Groups
		-->
		<Group name="L-S-T0" Category="Security" Scope="domainLocal" Description="Members of this group are part of Tier 0 administrative assets" Path="OU=GroupsT0,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T0_Managers" />
			<Member samAccountName="G-S-T0_Operators" />
		</Group>
		<Group name="L-S-T1" Category="Security" Scope="domainLocal" Description="Members of this group are part of Tier 1 administrative assets" Path="OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1_Managers" />
			<Member samAccountName="G-S-T1_Administrators" />
			<Member samAccountName="G-S-T1_Operators" />
		</Group>
		<Group name="L-S-T2" Category="Security" Scope="domainLocal" Description="Members of this group are part of Tier 2 administrative assets" Path="OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Managers" />
			<Member samAccountName="G-S-T2_Administrators" />
			<Member samAccountName="G-S-T2_Operators" />
		</Group>
		<Group name="L-S-T1L" Category="Security" Scope="domainLocal" Description="Members of this group are part of Legacy servers' administrative assets" Path="OU=GroupsT1L,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1L_Operators" />
		</Group>
		<Group name="L-S-T2L" Category="Security" Scope="domainLocal" Description="Members of this group are part of Legacy servers' administrative assets" Path="OU=GroupsT2L,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2L_Operators" />
		</Group>
		<!--
			PAW Groups
		-->
		<Group name="L-S-T0_PawAccess_Logon" Category="Security" Scope="domainLocal" Description="Members of this group will be able to connect to the first level administration stations" Path="OU=Logon,OU=GroupsT0,OU=_Administration,ROOTDN">
		</Group>
		<Group name="L-S-T0_PawT0_Logon" Category="Security" Scope="domainLocal" Description="Members of this group will be able to connect to the T0 administration stations" Path="OU=Logon,OU=GroupsT0,OU=_Administration,ROOTDN">
			<Member samAccountName="L-S-T0" />
		</Group>
		<Group name="L-S-T0_PawT12L_Logon" Category="Security" Scope="domainLocal" Description="Members of this group will be able to connect to the T1, T2 and TLegacy administration stations" Path="OU=Logon,OU=GroupsT0,OU=_Administration,ROOTDN">
			<Member samAccountName="L-S-T1" />
			<Member samAccountName="L-S-T2" />
			<Member samAccountName="L-S-T1L" />
			<Member samAccountName="L-S-T2L" />
		</Group>
		<!--
			Local Admins Groups
		-->
		<Group name="L-S-T0_LocalAdmins_Servers" Category="Security" Scope="domainLocal" Description="Members of this group will become member of the builtin\administrators group" Path="OU=LocalAdmins,OU=GroupsT0,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T0_Operators" />
		</Group>
		<Group name="L-S-T1_LocalAdmins_Servers" Category="Security" Scope="domainLocal" Description="Members of this group will become member of the builtin\administrators group" Path="OU=LocalAdmins,OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1_Operators" />
		</Group>
		<Group name="L-S-T1L_LocalAdmins_Servers" Category="Security" Scope="domainLocal" Description="Members of this group will become member of the builtin\administrators group" Path="OU=LocalAdmins,OU=GroupsT1L,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1L_Operators" />
		</Group>
		<Group name="L-S-T0_LocalAdmins_Workstations" Category="Security" Scope="domainLocal" Description="Members of this group will become member of the builtin\administrators group" Path="OU=LocalAdmins,OU=GroupsT0,OU=_Administration,ROOTDN">
		</Group>
		<Group name="L-S-T2_LocalAdmins_Workstations" Category="Security" Scope="domainLocal" Description="Members of this group will become member of the builtin\administrators group" Path="OU=LocalAdmins,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Operators" />
		</Group>
		<Group name="L-S-T2L_LocalAdmins_Workstations" Category="Security" Scope="domainLocal" Description="Members of this group will become member of the builtin\administrators group" Path="OU=LocalAdmins,OU=GroupsT2L,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2L_Operators" />
		</Group>
		<!--
			Builtin Groups
		-->
		<!-- FR-FR -->
		<!--
		<Group name="Administrateurs de l’entreprise" Category="Security" Scope="Universal" Description="" Path="CN=Users,ROOTDN">
			<Member samAccountName="G-S-T0_Managers" />
		</Group>
		-->
		<!-- FR-FR -->
		<!-- EN-US -->
		<Group name="Enterprise Admins" Category="Security" Scope="Universal" Description="" Path="CN=Users,ROOTDN">
			<Member samAccountName="G-S-T0_Managers" />
		</Group>
		<!-- EN-US -->
		<Group name="Protected Users" Category="Security" Scope="Global" Description="" Path="CN=Users,ROOTDN">
			<Member samAccountName="G-S-T0_Managers" />
		</Group>
		<!-- 
			Delegation groups on Administration OU
		-->
		<Group name="L-S-T1-DELEG_Group - Create and Delete (administration)" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete groups within Tier 1 _Administration OU" Path="OU=Deleg,OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1_Managers" />
		</Group>
		<Group name="L-S-T2-DELEG_Group - Create and Delete (administration)" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete groups within Tier 1 _Administration OU" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Managers" />
		</Group>
		<Group name="L-S-T1-DELEG_User - Create and Delete (administration)" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete users within Tier 1 administration OU" Path="OU=Deleg,OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1_Managers" />
		</Group>
		<Group name="L-S-T2-DELEG_User - Create and Delete (administration)" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete users within Tier 1 administration OU" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Managers" />
		</Group>
		<!-- 
			Delegation groups on Production and Legacy OU
		-->
		<Group name="L-S-T1-DELEG_Group - Create and Delete" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete groups within productions OUs (Tier 1 and 2)" Path="OU=Deleg,OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1_Administrators" />
			<Member samAccountName="G-S-T1_Managers" />
		</Group>
		<Group name="L-S-T2-DELEG_Group - Manage Membership" Category="Security" Scope="domainLocal" Description="Members of this group can add and remove members of tier 1 groups within productions OUs" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Administrators" />
			<Member samAccountName="G-S-T2_Managers" />
		</Group>
		<Group name="L-S-T1-DELEG_User - Create and Delete" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete users within productions OUs (Tier 1 and 2)" Path="OU=Deleg,OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1_Administrators" />
			<Member samAccountName="G-S-T1_Managers" />
		</Group>
		<Group name="L-S-T2-DELEG_User - Create and Delete" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete users within productions OUs (Tier 1 and 2)" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Administrators" />
			<Member samAccountName="G-S-T2_Managers" />
		</Group>
		<Group name="L-S-T1-DELEG_Computer - Create and Delete" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete computers within productions OUs (Tier 1 and 2)" Path="OU=Deleg,OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1_Administrators" />
			<Member samAccountName="G-S-T1_Managers" />
		</Group>
		<Group name="L-S-T2-DELEG_Computer - Create and Delete" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete computers within productions OUs (Tier 1 and 2)" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Administrators" />
			<Member samAccountName="G-S-T2_Managers" />
		</Group>
		<Group name="L-S-T2-DELEG_Contact - Create and Delete" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete contact within productions OUs (Tier 1 and 2)" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Administrators" />
			<Member samAccountName="G-S-T2_Managers" />
		</Group>
		<!-- 
			Delegation groups used through LAPS
		-->
		<Group name="L-S-T1-DELEG_LAPS_PwdRead" Category="Security" Scope="domainLocal" Description="Members of this group will be able to read LAPS password for workstations" Path="OU=Deleg,OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1_Operators" />
		</Group>
		<Group name="L-S-T2-DELEG_LAPS_PwdRead" Category="Security" Scope="domainLocal" Description="Members of this group will be able to read LAPS password for workstations" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Operators" />
		</Group>
		<Group name="L-S-T1-DELEG_LAPS_PwdReset" Category="Security" Scope="domainLocal" Description="Members of this group will be able to reset LAPS password for workstations" Path="OU=Deleg,OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1_Operators" />
		</Group>
		<Group name="L-S-T2-DELEG_LAPS_PwdReset" Category="Security" Scope="domainLocal" Description="Members of this group will be able to reset LAPS password for workstations" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Operators" />
		</Group>
		<!-- 
			Delegation groups Exchange Online (for futur implementation - not used yet)
		-->
		<Group name="L-S-T2-DELEG_ExchContact - Create and Delete" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete contact within Exchange OU" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Administrators" />
			<Member samAccountName="G-S-T2_Managers" />
		</Group>
		<Group name="L-S-T2-DELEG_ExchSharedMbx - Create and Delete" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete User within Exchange OU" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Administrators" />
			<Member samAccountName="G-S-T2_Managers" />
		</Group>
		<Group name="L-S-T2-DELEG_ExchDistributionGroup - Create and Delete" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete Group within Exchange OU" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Administrators" />
			<Member samAccountName="G-S-T2_Managers" />
		</Group>
		<Group name="L-S-T2-DELEG_ExchResource - Create and Delete" Category="Security" Scope="domainLocal" Description="Members of this group can create, update and delete User within Exchange OU" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Administrators" />
			<Member samAccountName="G-S-T2_Managers" />
		</Group>
		<!--
			Delegation Computer Domain join
		-->
		<Group name="L-S-T0-DELEG_Computer - Join Domain" Category="Security" Scope="domainLocal" Description="Members of this group can join a system to the Tier 0 OU" Path="OU=Deleg,OU=GroupsT0,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T0_Operators" />
		</Group>
		<Group name="L-S-T1-DELEG_Computer - Join Domain" Category="Security" Scope="domainLocal" Description="Members of this group can join a system to the Tier 1 OU" Path="OU=Deleg,OU=GroupsT1,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T1_Operators" />
		</Group>
		<Group name="L-S-T2-DELEG_Computer - Join Domain" Category="Security" Scope="domainLocal" Description="Members of this group can join a system to the Tier 2 OU" Path="OU=Deleg,OU=GroupsT2,OU=_Administration,ROOTDN">
			<Member samAccountName="G-S-T2_Operators" />
		</Group>
	</Groups>
	<DefaultMembers>
		<!--
			The <DefaultMembers> Section list strictely allowed members of a specified group.
			
			When the script call the function "Reset-GroupMembership", the function will use this data to leave only mandatory identity.
			> Member: either a SID or a sAMAccountName. Use %domainSID% to dynamically replace it by the domain SID.

			A Group Target can be asked to perform any ot the follwing actions through the parameter AllowedTo:
			> AddOnly: (default) If any of the specified members is missing, then the object will be added.
			> Enforce: When used, the script drops all of the group members and add only the ones specified here.
		-->
		<!-- 
			Builtin\Administrators 
		-->
		<Group Target="S-1-5-32-544" AllowedTo="AddOnly">
			<Member>%DomainSID%-500</Member>
			<Member>%DomainSID%-512</Member>
			<Member>%DomainSID%-519</Member>
		</Group>
		<!-- 
			Domain Admins 
		-->
		<Group Target="%DomainSID%-512" AllowedTo="AddOnly">
			<Member>%DomainSID%-500</Member>
		</Group>
		<!-- 
			Enterprise Admins 
		-->
		<Group Target="%DomainSID%-519" AllowedTo="AddOnly">
			<Member>%t0-Managers%</Member>
		</Group>
		<!-- 
			Protected Users 
		-->
		<Group Target="%DomainSID%-525" AllowedTo="AddOnly">
			<Member>%t0-managers%</Member>
		</Group>
	</DefaultMembers>
	<TaskSchedules BaseDir="%Windir%\HardenAD\TasksSchedulesScripts">
		<!--
			The <TaskSchedules> section define the sched. tasks to add to the running system and is called by the function New-ScheduleTasks.
			The following parameters are expected:
				> Name......: The scheduled tasks name, as shown in the GUI.
				> Xml.......: The xml file containing a backup of the new scheduled tasks and located in .\Inputs\ScheduleTasks\TasksSchedulesXml
				> SchedCmd..: The executable to be used. It will replace the %command% in the xml file.
				> SchedArg..: The arguments line to pass to the executable. If a script is specified, it should present in .\Inputs\ScheduleTasks\TasksSchedulesScripts
				> SchedDir..: The effective path context when the schedule is run - use %BaseDir% to refer to the directory value speciefied in the "BaseDir" parameters of the section <TaskSchedules> (this one, yup).
				> SchedDsc..: The description field for this task.
				> SchedPth..: The folder name where the task will be stored in the Tasks Scheduler console.
		-->
		<!-- 
			flushing Sensible groups with MCS-GroupsFlushing.ps1 
		-->
		<SchedTask Name="MCS - Sensitive Groups Flushing" Xml="MCS-GroupsFlushing.xml">
			<SchedCmd>powershell.exe</SchedCmd>
			<SchedArg>-windowstyle hidden -file .\MCS-GroupsFlushing.ps1</SchedArg>
			<SchedDir>%BaseDir%\MCS-GroupsFlushing</SchedDir>
			<SchedDsc>Flush highly sensitive groups (see MCS-GroupsScheduling.csv for details)</SchedDsc>
			<SchedPth>HardenAD</SchedPth>
		</SchedTask>
	</TaskSchedules>
	<LocalAdminPasswordSolution>
		<!--
			The <LocalAdminPasswordSolution> is used to setup LAPS over an existing domain.
			By default, the model delegate permission to Tier 1 for servers and Tier 2 for workstations. All others are handled by Dom admins.

			SelfPermission: Add Write Permission to ms-Mcs-AdmPwdExiprationTime and ms-Mcs-AdmPwd attribute to SELF (i.e. the computer object).
			PasswordReader: Offer the ability to read ms-Mcs-AdmPwd which contains the local user password
			PasswordReset.: Offer the ability to read and write ms-Mcs-AdmPwdExiprationTime and ms-Mcs-AdmPwd attribute

			The script now handles dynamic group mapping and will look at the <Translation> section of this document.

			<AdmPwdSelfPermission>:
				Target: target OU distinguished name with computer objects. use "RootDN" to dynamically specify the domain distanguished name.

			<AdmPwdPasswordreader>:
				Target: target OU distinguished name with computer objects. use "RootDN" to dynamically specify the domain distanguished name.
				Id....: Specific the group sAMAccountName to be granted with the password read permission on the target OU.

			<AdmPwdPasswordreset>:
				Target: target OU distinguished name with computer objects. use "RootDN" to dynamically specify the domain distanguished name.
				Id....: Specific the group sAMAccountName to be granted with the password reset permission on the target OU.
		-->
		<!--
			Self Permissions
		-->
		<AdmPwdSelfPermission Target="OU=PawT0,OU=_Administration,%DN%" />
		<AdmPwdSelfPermission Target="OU=PawT12L,OU=_Administration,%DN%" />
		<AdmPwdSelfPermission Target="OU=PawAccess,OU=_Administration,%DN%" />
		<AdmPwdSelfPermission Target="OU=Servers,OU=Harden_TL,%DN%" />
		<AdmPwdSelfPermission Target="OU=Servers,OU=Harden_T12,%DN%" />
		<AdmPwdSelfPermission Target="OU=Workstations,OU=Harden_TL,%DN%" />
		<AdmPwdSelfPermission Target="OU=Workstations,OU=Harden_T12,%DN%" />
		<!--
			Password Reader Permissions
		-->
		<AdmPwdPasswordReader Target="OU=Servers,OU=Harden_TL,%DN%" Id="%NetBios%\%T1-LAPS-PasswordReader%" />
		<AdmPwdPasswordReader Target="OU=Servers,OU=Harden_T12,%DN%" Id="%NetBios%\%T1-LAPS-PasswordReader%" />
		<AdmPwdPasswordReader Target="OU=Workstations,OU=Harden_TL,%DN%" Id="%NetBios%\%T2-LAPS-PasswordReader%" />
		<AdmPwdPasswordReader Target="OU=Workstations,OU=Harden_T12,%DN%" Id="%NetBios%\%T2-LAPS-PasswordReader%" />
		<!-- 
			Password Reset Permissions
		-->
		<AdmPwdPasswordReset Target="OU=Servers,OU=Harden_TL,%DN%" Id="%NetBios%\%T1-LAPS-PasswordReset%" />
		<AdmPwdPasswordReset Target="OU=Servers,OU=Harden_T12,%DN%" Id="%NetBios%\%T1-LAPS-PasswordReset%" />
		<AdmPwdPasswordReset Target="OU=Workstations,OU=Harden_TL,%DN%" Id="%NetBios%\%T2-LAPS-PasswordReset%" />
		<AdmPwdPasswordReset Target="OU=Workstations,OU=Harden_T12,%DN%" Id="%NetBios%\%T2-LAPS-PasswordReset%" />
	</LocalAdminPasswordSolution>
	<Sequence>
		<!-- 
			The <Sequence> section define the different tasks to iterate in "sequence" (can't resist to this one).
    		To deal with highlight color in display, use the ` to initiate and end a color change in your string, then use one of the three
    		characters specified in value AltBaseHTxt(A,B, or C) to select your color: the color will switch back to normal at the next `.

			The default highlight values are those one:
				> `[my text` : magenta
				> `(my text` : yellow
				> `{my text` : gray

			Some special inputs are usefull to replace value dynamically :
				> FileName   : replace with the value of this file
				> RootDN     : replace with domain root DN

			Each task ID is executed in sequence, based on the Number vaue (ascending). Each Task ID use the following attributes:
				> Number         : Define the squence order, the lowest will be run first.
				> Name           : ID task name as refered in the final log output.
				> CallingFunction: Name of the function to be called from one of the .psm1 files present in the modules directory.
				> UseParameters  : Mandatory (but could be empty). Specify parameter to pass as argument to CallingFunction.
				                   Use on per parameter and sort them in sequence (your script should refer them using input ordering).
				> TaskEnabled    : YES or NO. When set to NO, the tasks is disabled and will not be applied.
		-->
		<!-- 
			Upgrade Domain Functional Level
		-->
		<Id Number="005" Name="Upgrade Domain Functional Level">
			<CallingFunction>Set-ADFunctionalLevel</CallingFunction>
			<UseParameters>Domain</UseParameters>
			<UseParameters>Last</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Upgrade `(DomainFunctionalLevel` </TaskDescription>
		</Id>
		<!-- 
			Upgrade Forest Functional Level
		-->
		<Id Number="006" Name="Upgrade Forest Functional Level">
			<CallingFunction>Set-ADFunctionalLevel</CallingFunction>
			<UseParameters>Forest</UseParameters>
			<UseParameters>Last</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Upgrade `(ForestFunctionalLevel` </TaskDescription>
		</Id>
		<!-- 
			SET MS-DS-MACHINEACCOUNTQUOTA TO 0
		-->
		<Id Number="010" Name="Restrict computer junction to the domain">
			<CallingFunction>Set-msDSMachineAccountQuota</CallingFunction>
			<UseParameters>0</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>set `(msDSMachineAccountQuota` to `(0` to restrict domain junction</TaskDescription>
		</Id>
		<!-- 
			ENABLE THE AD RECYCLE BIN
		-->
		<Id Number="020" Name="Activate Active Directory Recycle Bin">
			<CallingFunction>Set-ADRecycleBin</CallingFunction>
			<UseParameters>
			</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>activate the `(AD Recycle Bin` optional feature</TaskDescription>
		</Id>
		<!-- 
			CONFIGURE ALL AD SITE LINKS WITH THE NOTIFY OPTIONS
		-->
		<Id Number="030" Name="Set Notify on every Site Links">
			<CallingFunction>Set-SiteLinkNotify</CallingFunction>
			<UseParameters>
			</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>set `(notify` on every `(Site Links</TaskDescription>
		</Id>
		<!-- 
			ACTIVATE THE GPO CENTRAL STORE
		-->
		<Id Number="040" Name="Set GPO Central Store">
			<CallingFunction>Set-GpoCentralStore</CallingFunction>
			<UseParameters>
			</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>set `(GPO Central Store` and `(update adm and admx` files</TaskDescription>
		</Id>
		<!-- 
			GENERATE NEW ADMINISTRATION ORGANIZATIONAL UNIT
		-->
		<Id Number="050" Name="Set Administration Organizational Unit">
			<CallingFunction>Set-TreeOU</CallingFunction>
			<UseParameters>HardenAD_ADMIN</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>set `(Administration` organizational unit</TaskDescription>
		</Id>
		<!-- 
			GENERATE NEW TIER 0 ORGANIZATIONAL UNIT
		-->
		<Id Number="051" Name="Set Tier 0 Organizational Unit">
			<CallingFunction>Set-TreeOU</CallingFunction>
			<UseParameters>HardenAD_PROD-T0</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>set `(Tier 0` organizational unit</TaskDescription>
		</Id>
		<!-- 
			GENERATE NEW TIER 1 and 2 ORGANIZATIONAL UNIT
		-->
		<Id Number="052" Name="Set Tier 1 and Tier 2 Organizational Unit">
			<CallingFunction>Set-TreeOU</CallingFunction>
			<UseParameters>HardenAD_PROD-T1and2</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>set `(Tier 1 and Tier 2 combo` organizational unit</TaskDescription>
		</Id>
		<!-- 
			GENERATE NEW LEGACY ORGANIZATIONAL UNIT
		-->
		<Id Number="053" Name="Set Legacy Organizational Unit">
			<CallingFunction>Set-TreeOU</CallingFunction>
			<UseParameters>HardenAD_PROD-LEGACY</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>set `(Tier Legacy` organizational unit</TaskDescription>
		</Id>
		<!-- 
			GENERATE NEW DEFAULT OBJECTS LOCATION TREE
		-->
		<Id Number="060" Name="Set Provisioning Organizational Unit">
			<CallingFunction>Set-TreeOU</CallingFunction>
			<UseParameters>PROVISIONNING-EN</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>set `(Provisioning` organizational unit</TaskDescription>
		</Id>
		<!-- 
			RELOCATE NEW USER/GROUP OBJECT LOCATION
		-->
		<Id Number="070" Name="Default user location on creation">
			<CallingFunction>Set-DefaultObjectLocation</CallingFunction>
			<UseParameters>User</UseParameters>
			<UseParameters>OU=users,OU=provisioning,RootDN</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>set `(user objects` default location</TaskDescription>
		</Id>
		<!-- 
			RELOCATE NEW COMPUTER OBJECT LOCATION
		-->
		<Id Number="071" Name="Default computer location on creation">
			<CallingFunction>Set-DefaultObjectLocation</CallingFunction>
			<UseParameters>Computer</UseParameters>
			<UseParameters>OU=computers,OU=provisioning,RootDN</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>set `(computer objects` default location</TaskDescription>
		</Id>
		<!-- 
			GENERATE NEW ADMIN ACCOUNTS ON WHICH THE DELEGATION MODEL WILL WORKS
		-->
		<Id Number="080" Name="Create administration accounts">
			<CallingFunction>New-AdministrationAccounts</CallingFunction>
			<UseParameters>H4rd3n@D!!</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>create `(administration accounts` used by the tier model</TaskDescription>
		</Id>
		<!-- 
			GENERATE NEW ADMIN GROUPS ON WHICH THE DELEGATION MODEL WILL WORKS
		-->
		<Id Number="090" Name="Create administration groups">
			<CallingFunction>New-AdministrationGroups</CallingFunction>
			<UseParameters>
			</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>create `(administration groups` used by the tier model</TaskDescription>
		</Id>
		<!-- 
			ACEs DEPLOYMENT FOR DELEGATION MODEL
		-->
		<Id Number="095" Name="Enforce delegation model through ACEs">
			<CallingFunction>Push-DelegationModel</CallingFunction>
			<UseParameters>
			</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Enforce `(Delegation ACEs` used by the tier model</TaskDescription>
		</Id>
		<!--
			FILE CUSTOMIZATION BEFORE GPO IMPORT
		-->
		<Id Number="100" Name="Prepare GPO files before GPO import">
			<CallingFunction>Set-TSLocalAdminGroups</CallingFunction>
			<UseParameters>{60C4FFE1-F082-49EE-9AF2-F7ABA228D05F}</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Prepare `(Configuration.xml` before the GPO importation of '`(HAD-TS-Local-admins-groups`'</TaskDescription>
		</Id>
		<!-- 
			IMPORT WMI FILTERS
		-->
		<Id Number="125" Name="Import additional WMI Filters">
			<CallingFunction>Import-WmiFilters</CallingFunction>
			<UseParameters>
			</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Import `(WMI filter` to the domain</TaskDescription>
		</Id>
		<!-- 
			IMPORT GPOs
		-->
		<Id Number="130" Name="Import new GPO or update existing ones">
			<CallingFunction>New-GpoObject</CallingFunction>
			<UseParameters>
			</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Import or update `(group policy objects` to the domain and link them</TaskDescription>
		</Id>
		<!-- 
			LAPS SCHEMA UPDATE AND POWERSHELL TOOLING DEPLOYMENT
			Warning: this only works with .Net 4.0 or greater.
		-->
		<Id Number="134" Name="Update Ad schema for LAPS and deploy PShell tools">
			<CallingFunction>Install-Laps</CallingFunction>
			<UseParameters>ForceDcIsSchemaOwner</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Update `(AD Schema` for `[LAPS` and add `(PShell add-on`</TaskDescription>
		</Id>
		<!-- 
			LAPS PERMISSIONS DEPLOYMENT OVER THE DOMAIN
		-->
		<Id Number="135" Name="Setup LAPS permissions over the domain">
			<CallingFunction>Set-LapsPermissions</CallingFunction>
			<UseParameters>CUSTOM</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Set-up `(LAPS` permissions on the target domain</TaskDescription>
		</Id>
		<!-- 
			LAPS DEPLOYMENT SCRIPT UDATE
		-->
		<Id Number="136" Name="Update LAPS deployment scripts">
			<CallingFunction>Set-LapsScripts</CallingFunction>
			<UseParameters>NETLOGON\LAPS</UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Update `(LAPS Scripts` to match with the domain name</TaskDescription>
		</Id>
		<!-- 
			UPDATE SENSIBLE GROUPS
		-->
		<Id Number="150" Name="Reset HAD Protected Groups Memberships">
			<CallingFunction>Reset-GroupMembership</CallingFunction>
			<UseParameters></UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Update `(groups' memberships` to match the `[trusted list`</TaskDescription>
		</Id>
		<!-- 
			CROSS INTEGRATION OF ADMIN GROUPS (disabled for rewriting in 2.9.9)
		-->
		<!--
		<Id Number="160" Name="Cross integration of Admin groups">
			<CallingFunction>Add-GroupsOverDomain</CallingFunction>
			<UseParameters></UseParameters>
			<TaskEnabled>No</TaskEnabled>
			<TaskDescription>Cross integration of `(administration groups` used by the tier model</TaskDescription>
		</Id>
		-->
	</Sequence>
</Settings>
#>
[xml]$XAML = @"
<Window x:Class="MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Harden AD" Width="1010" Height="650" ResizeMode="NoResize" WindowStartupLocation="CenterScreen" mc:Ignorable="d" Icon="$icon">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <StackPanel Grid.Row="0">
			<TextBlock Text="$labelText1" FontWeight="Bold" HorizontalAlignment="Center" TextWrapping="Wrap" TextAlignment="Center" />
            <TextBlock Text="$labelText2" FontWeight="Bold" HorizontalAlignment="Center" TextWrapping="Wrap" TextAlignment="Center" />
            <TextBlock Text="$labelText3" FontWeight="Bold" HorizontalAlignment="Center" TextWrapping="Wrap" TextAlignment="Center" Padding="2" Foreground="Red"/>
        </StackPanel>
		<TabControl Grid.Row="1">
            <TabItem Header="Task Sequence">
				<ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto">
					<Grid>
						<Grid.RowDefinitions>
							<RowDefinition Height="Auto"/>
							<RowDefinition Height="*"/>
						</Grid.RowDefinitions>
						<Grid Margin="5" x:Name="MyGrid" Grid.Row="0">
							<Grid.ColumnDefinitions>
								<ColumnDefinition Width="*"></ColumnDefinition>
								<ColumnDefinition Width="*"></ColumnDefinition>
							</Grid.ColumnDefinitions>
							<Grid.RowDefinitions>
								$($rowArray -join "`n")
							</Grid.RowDefinitions>
							$($checkboxesArray -join "`n")
						</Grid>
						<Button x:Name="CheckUncheckAllButton_Tasks" Content="Check/Uncheck all tasks" Grid.Row="1" HorizontalAlignment="Center" Height="20"/>
					</Grid>
				</ScrollViewer>
            </TabItem>
            <TabItem Header="Group Policies">
       			<ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto">
					<Grid>
						<Grid.RowDefinitions>
							<RowDefinition Height="Auto"/>
							<RowDefinition Height="*"/>
						</Grid.RowDefinitions>
						<Grid Margin="5" x:Name="MyGrid2" Grid.Row="0">
							<Grid.ColumnDefinitions>
								<ColumnDefinition Width="*"></ColumnDefinition>
								<ColumnDefinition Width="*"></ColumnDefinition>
								<ColumnDefinition Width="*"></ColumnDefinition>
								<ColumnDefinition Width="*"></ColumnDefinition>
							</Grid.ColumnDefinitions>
							<Grid.RowDefinitions>
								$($groupPoliciesRowsArray -join "`n")
							</Grid.RowDefinitions>
							$($groupPoliciesCheckboxesArray -join "`n")
						</Grid>
						<Button x:Name="CheckUncheckAllButton_GPO" Content="Check/Uncheck all policies" Grid.Row="1" HorizontalAlignment="Center" Height="20"/>
					</Grid>
				</ScrollViewer>
            </TabItem>
        </TabControl>
        <DockPanel Grid.Row="2" LastChildFill="False" Background="#f3f3f3" HorizontalAlignment="Stretch" Width="Auto" VerticalAlignment="Center">
            <StackPanel Orientation="Horizontal" DockPanel.Dock="Right">
                <TextBlock x:Name="SaveLabel" Text="" VerticalAlignment="Center" Margin="5" FontStyle="Italic"/>
                <Button x:Name="SaveButton" Content="Save" Padding="7" Margin="5" Width="80"/>
                <Button x:Name="ExitButton" Content="Exit" Padding="7" Margin="5" Width="80"/>
            </StackPanel>
        </DockPanel>
    </Grid>
</Window>
"@ -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' -replace 'x:Class="\S+"', ''

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $XAML)
$Form = [Windows.Markup.XamlReader]::Load($reader)

$XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name) }

#endregion

# Add Click event handler
$CheckUncheckAllButton_Tasks.Add_Click({
		# Get all CheckBoxes
		$checkBoxes = $Form.FindName("MyGrid").Children | Where-Object { $_ -is [System.Windows.Controls.CheckBox] }
		# Check if all CheckBoxes are checked
		$allChecked = ($checkBoxes | ForEach-Object { $_.IsChecked }) -notcontains $false
		# Check or uncheck all CheckBoxes
		$checkBoxes | ForEach-Object { $_.IsChecked = -not $allChecked }
	})

# Add Click event handler
$CheckUncheckAllButton_GPO.Add_Click({
		# Get all CheckBoxes
		$checkBoxes = $Form.FindName("MyGrid2").Children | Where-Object { $_ -is [System.Windows.Controls.CheckBox] }
		# Check if all CheckBoxes are checked
		$allChecked = ($checkBoxes | ForEach-Object { $_.IsChecked }) -notcontains $false
		# Check or uncheck all CheckBoxes
		$checkBoxes | ForEach-Object { $_.IsChecked = -not $allChecked }
	})

$SaveButton.Add_Click({
		# get all CheckBoxes and update the XML configuration file
		$checkBoxes = $Form.FindName("MyGrid").Children | Where-Object { $_ -is [System.Windows.Controls.CheckBox] }
		# if ID 130 is checked, then ID 125 must be checked
		# If not, I want to raise a pop-up message
		$checkBox100 = $checkBoxes | Where-Object { $_.Name -eq "ID_100" }
		$checkBox125 = $checkBoxes | Where-Object { $_.Name -eq "ID_125" }
		$checkBox300 = $checkBoxes | Where-Object { $_.Name -eq "ID_130" }
		
		if ($checkBox300.IsChecked -and (-not ($checkBox125.IsChecked) -or -not ($checkBox100.IsChecked))) {
			$ID100DisplayName = $checkBox100.Content
			$ID125DisplayName = $checkBox125.Content
			$ID300DisplayName = $checkBox300.Content
			
			$message = "You must check the following tasks before checking the task `n'$ID300DisplayName'`:`n`n - $ID100DisplayName`n - $ID125DisplayName"
			[System.Windows.MessageBox]::Show($message, "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
			
			return
		}

		foreach ($checkBox in $checkBoxes) {
			$number = $checkBox.Name -replace 'ID_', ''
			$taskNode = Select-Xml $TasksSeqConfig -XPath "//Sequence/Id[@Number='$number']" | Select-Object -ExpandProperty "Node"
        
			if ($checkBox.IsChecked -eq $true) {
				$taskNode.TaskEnabled = "Yes"
			}
			else {
				$taskNode.TaskEnabled = "No"
			}
		}

		# get all CheckBoxes and update the XML configuration file
		$checkBoxes = $Form.FindName("MyGrid2").Children | Where-Object { $_ -is [System.Windows.Controls.CheckBox] }
		foreach ($checkBox in $checkBoxes) {
			$number = [int]($checkBox.Name -replace 'ID_', '')
			
			# get GUID from ID
			$gpoGUID = $gpoGUIDHashTables[$number]

			#$gpoNode = Select-Xml $TasksSeqConfig -XPath "//GPO[@BackupID='{3B8C8687-8779-4042-AFF9-83F88BB4B894}']")]" | Select-Object -ExpandProperty "Node"
			$gpoNode = Select-Xml $TasksSeqConfig -XPath "//GPO[@BackupID='$gpoGUID']" | Select-Object -ExpandProperty "Node"

			if ($checkBox.IsChecked) {
				$gpoNode.Validation = "Yes"
			}
			else {
				$gpoNode.Validation = "No"
			}
		}

		# Saving file
		Format-XMLData -XMLData $TasksSeqConfig | Out-File $configXMLFilePath -Encoding utf8 -Force
        
		$SaveLabel.Text = "$([System.DateTime]::Now.ToString('HH:mm:ss')) - File $configXMLFileName saved!"
	})

$Form.FindName("ExitButton").Add_Click({ $Form.Close() })

$dialogResult = $Form.ShowDialog()