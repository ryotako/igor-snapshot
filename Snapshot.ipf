#ifndef LOADED_SNAPSHOT
#define LOADED_SNAPSHOT
#pragma ModuleName=Snapshot

// Constants
constant    Snapshot_Resolution = 4 // 4 is default value of Igor Pro  
constant    Snapshot_ColorPrint = 0 // 0 means RGB and the others means CMYK
strconstant Snapshot_Menu = "Snapshot"
strconstant Snapshot_DefaultFormat = "png" // pdf, tiff, jpeg, png, pict, or eps
strconstant Snapshot_DefaultHook = "" // BeforeSave, BeforeQuit, or BeforeSave;BeforeQuit

// Static Constants
static constant TRUE =1
static constant FALSE=0


// Menu
Menu Snapshot_Menu
	"(Format: "+Snapshot_DefaultFormat
	"---"
	"Save All Graphs",/Q,Snapshot#SaveAll()
	"Show Saved Graphs",/Q,Snapshot#ShowDirectory()
	SubMenu "Auto Save"
		Snapshot#CheckMark("hookBeforeSave")+"Before Save",/Q,Snapshot#Toggle("hookBeforeSave")
		Snapshot#CheckMark("hookBeforeQuit")+"Before Quit",/Q,Snapshot#Toggle("hookBeforeQuit")
	End
End

// Functions
static Function SaveAll()
	String wins = WinList("*",";","WIN:1")
	Variable i,Ni=ItemsInList(wins)
	for(i=0;i<Ni;i+=1)
		Snapshot(StringFromList(i,wins))
	endfor
End

static Function Snapshot(win)
	String win
	String path =  Directory()
	Variable res = 72*Snapshot_Resolution
	Variable clr = SNAPSHOT_COLORPRINT ? 2 : 1
	Variable fmt = Format(Snapshot_DefaultFormat)
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
	NVAR v=$"root:Packages:Snapshot:"+"hookBeforeSave"
	if(NVAR_Exists(v))
		if(v)
			Snapshot#SaveAll()
		endif
	else
		if(WhichListItem("BeforeHook",Snapshot_DefaultHook,";",0,0)>=0)
			Snapshot#SaveAll()
		endif
	endif
End
static Function IgorQuitHook(igorApplicationNameStr)
	String igorApplicationNameStr
	NVAR v=$"root:Packages:Snapshot:"+"hookBeforeQuit"
	if(NVAR_Exists(v))
		if(v)
			Snapshot#SaveAll()
		endif
	else
		if(WhichListItem("BeforeQuit",Snapshot_DefaultHook,";",0,0)>=0)
			Snapshot#SaveAll()
		endif
	endif
End
static Function IgorBeforeNewHook(igorApplicationNameStr)
	String igorApplicationNameStr
	return IgorQuitHook(igorApplicationNameStr)
End


static Function Toggle(name)
	String name
	NVAR v=$"root:Packages:Snapshot:"+name
	if(NVAR_Exists(v))
		v = v ? FALSE : TRUE
	else
		SetVar(name,TRUE)
	endif
End
static Function SetVar(name,value)
	String name; Variable value
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Snapshot
	String path = "root:Packages:Snapshot:"+name
	Variable/G $path
	NVAR v=$path; v=value
End

static Function/S CheckMark(name)
	String name
	NVAR v = $"root:Packages:Snapshot:"+name
	String checkmark = "!"+num2char(18) // "!"+num2char(18) means a checkmark for Windows and Macintosh
	if(NVAR_Exists(v))
		return SelectString(v,"",checkmark)
	else
		StrSwitch(name)
		case "hookBeforeSave":
			return SelectString(WhichListItem("BeforeSave",Snapshot_DefaultHook,";",0,0)>=0,"",checkmark)		
		case "hookBeforeQuit":
			return SelectString(WhichListItem("BeforeQuit",Snapshot_DefaultHook,";",0,0)>=0,"",checkmark)				
		EndSwitch
	endif
	return ""
End

static Function/S Directory()
	PathInfo home
	String pRef ="Snapshot_Directory"
	if(strlen(S_path))
		String path=S_path+IgorInfo(1)+"_figures"
		NewPath/C/O/Q/Z $pRef path
		return pRef
	endif
End

static Function Format(name)
	String name
	StrSwitch(name)
	case "pdf":
		return -8
	case "tiff":
		return -7
	case "jpeg":
		return -6
	case "png":
		return -5
	case "pict":
		return -4
	case "eps":
		return -3
	case "os":
		return -2
	EndSwitch
End

