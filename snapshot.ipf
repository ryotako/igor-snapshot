#ifndef LOADED_SNAPSHOT
#define LOADED_SNAPSHOT
#pragma ModuleName=Snapshot

constant    Snapshot_Resolution = 4 // 4 is default value of Igor Pro  
constant    Snapshot_ColorPrint = 0 // 0 means RGB and the others means CMYK
strconstant Snapshot_Menu = "Snapshot"
strconstant Snapshot_DefaultFormat = "png" // pdf, tiff, jpeg, png, pict, or eps
strconstant Snapshot_DefaultHook = "" // BeforeSave, BeforeQuit, or BeforeSave;BeforeQuit

Menu StringFromList(0,Snapshot_Menu),dynamic
	RemoveListItem(0,Snapshot_Menu)
	"Save All Graphs"  ,/Q,Snapshot#SaveAll()
	"Show Saved Graphs",/Q,Snapshot#ShowDirectory()
	"-"
	SubMenu Snapshot#FormatMenuTitle()
		Snapshot#FormatMenuItem(0),/Q,Snapshot#FormatMenuCommand(0)
		Snapshot#FormatMenuItem(1),/Q,Snapshot#FormatMenuCommand(1)
		Snapshot#FormatMenuItem(2),/Q,Snapshot#FormatMenuCommand(2)
		Snapshot#FormatMenuItem(3),/Q,Snapshot#FormatMenuCommand(3)
		Snapshot#FormatMenuItem(4),/Q,Snapshot#FormatMenuCommand(4)
		Snapshot#FormatMenuItem(5),/Q,Snapshot#FormatMenuCommand(5)
	End
	SubMenu Snapshot#AutoSaveMenuTitle()
		Snapshot#AutoSaveMenuItem("Save"),/Q,Snapshot#AutoSaveMenuCommand("Save")
		Snapshot#AutoSaveMenuItem("Quit"),/Q,Snapshot#AutoSaveMenuCommand("Quit")
	End
End

// Fromat
static Function/S FormatMenuTitle()
	return "Format: "+GetSVAR("format",Snapshot_DefaultFormat)
End
static Function/S FormatMenuItem(i)
	Variable i
	String format = StringFromList(i,"pdf;tiff;jpeg;png;pict;eps")
	return Check(StringMatch(format,GetSVAR("format",Snapshot_DefaultFormat)))+format
End
static Function/S FormatMenuCommand(i)
	Variable i
	SetSVAR("format",StringFromList(i,"pdf;tiff;jpeg;png;pict;eps"))
End

// Auto Save
static Function/S AutoSaveMenuTitle()
	return "Auto Save"
End
static Function/S AutoSaveMenuItem(timing)
	String timing
	String name = "hookBefore"+timing
	return check(GetNVAR(name,Has(name,Snapshot_DefaultHook)))+"Save Before "+timing
End
static Function/S AutoSaveMenuCommand(timing)
	String timing
	String name = "hookBefore"+timing
	Toggle("hookBefore"+timing,Has(name,Snapshot_DefaultHook))
End

// Save
static Function SaveAll()
	String wins = WinList("*",";","WIN:1")
	Variable i,Ni=ItemsInList(wins)
	for(i=0;i<Ni;i+=1)
		SaveGraph(StringFromList(i,wins))
	endfor
End

static Function SaveGraph(win)
	String win
	String path =  Directory()
	Variable res = 72*Snapshot_Resolution
	Variable clr = SNAPSHOT_COLORPRINT ? 2 : 1
	Variable fmt = Format2Num(GetSVAR("format",Snapshot_DefaultFormat))
	PathInfo $path
	if(V_Flag)
		SavePict/B=(res)/C=(clr)/E=(fmt)/EF=2/O/S/WIN=$win/P=$path/Z
	endif
End

static Function ShowDirectory()
	PathInfo/SHOW $Directory()
End

// Hook Functions
static Function BeforeExperimentSaveHook(rN,fileName,path,type,creator,kind)
	Variable rN,kind; String fileName,path,type,creator
	if(GetNVAR("hookBeforeSave",has("hookBeforeSave",Snapshot_DefaultHook)))
		Snapshot#SaveAll()
	endif
End
static Function IgorQuitHook(igorApplicationNameStr)
	String igorApplicationNameStr
	if(GetNVAR("hookBeforeQuit",has("hookBeforeQuit",Snapshot_DefaultHook)))
		Snapshot#SaveAll()
	endif
End
static Function IgorBeforeNewHook(igorApplicationNameStr)
	String igorApplicationNameStr
	return IgorQuitHook(igorApplicationNameStr)
End

// Utils
static Function Toggle(name,default)
	String name; Variable default
	SetNVAR(name,!GetNVAR(name,default))
End
static Function SetNVAR(name,value)
	String name; Variable value
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Snapshot
	Variable/G $"root:Packages:Snapshot:"+name = value
End
static Function GetNVAR(name,default)
	String name; Variable default
	NVAR v=$"root:Packages:Snapshot:"+name
	return NVAR_Exists(v) ? v : default
End
static Function SetSVAR(name,value)
	String name,value
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Snapshot
	String/G $"root:Packages:Snapshot:"+name = value
End
static Function/S GetSVAR(name,default)
	String name,default
	SVAR s=$"root:Packages:Snapshot:"+name
	if(SVAR_Exists(s))
		return s
	else
		return default
	endif
End

static Function/S Check(bool)
	Variable bool
	return SelectString(bool,"","!"+num2char(18)) // "!"+num2char(18) means a checkmark for Windows and Macintosh
End

static Function Has(item,list)
	String item,list
	return WhichListItem(item,list,";",0,0)>=0
End

static Function Format2Num(name)
	String name
	return WhichListItem(name,"pdf;tiff;jpeg;png;pict;eps;os")-8
End

static Function/S Directory()
	PathInfo home
	if(strlen(S_path))
		String pRef ="Snapshot_Directory"
		NewPath/C/O/Q/Z $pRef S_path+IgorInfo(1)+"_figures"
		return pRef
	else
		return ""
	endif
End
