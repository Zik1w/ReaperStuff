--[[
 * ReaScript Name: XXXX
 * Author: Zik1
 * Author URI: 
 * Repository: 
 * Repository URI: https:
 * Licence: GPL v3
 * Forum Thread: Scripts: 
 * Forum Thread URI: 
 * REAPER: 6.7
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (XXXX-XX-XX)
  + Initial Release
--]]
 
-- USER CONFIG AREA ---------------------------------------------
--[[
-- Do you want a pop up to appear ?
CONFIG_UI_popup = true -- true/false use UI or not

-- Define here your default variables values
CONFIG_INPUT_1 = "word" -- % for escaping characters
CONFIG_INPUT_2 = "/del" -- "/del" for deletion
CONFIG_INPUT_3 = "0" -- number
CONFIG_INPUT_4 = "1" -- number
CONFIG_INPUT_5 = "y" -- y/n boolean
CONFIG_INPUT_6 = "n" -- y/n boolean
]]--


-- Updated from template provided by ReaScript Team, very appericated!
-----------------------------------------------------------------

function main() 

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- YOUR CODE BELOW

	-- LOOP THROUGH SELECTED ITEMS
	--[[
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	item_table = {}

	-- INITIALIZE loop through selected items
	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
		-- GET INFOS
		value_get = reaper.GetMediaItemInfo_Value(item, "D_VOL") -- Get the value of a the parameter
		--[[
		B_MUTE : bool * to muted state
		B_LOOPSRC : bool * to loop source
		B_ALLTAKESPLAY : bool * to all takes play
		B_UISEL : bool * to ui selected
		C_BEATATTACHMODE : char * to one char of beat attached mode, -1=def, 0=time, 1=allbeats, 2=beatsosonly
		C_LOCK : char * to one char of lock flags (&1 is locked, currently)
		D_VOL : double * of item volume (volume bar)
		D_POSITION : double * of item position (seconds)
		D_LENGTH : double * of item length (seconds)
		D_SNAPOFFSET : double * of item snap offset (seconds)
		D_FADEINLEN : double * of item fade in length (manual, seconds)
		D_FADEOUTLEN : double * of item fade out length (manual, seconds)
		D_FADEINLEN_AUTO : double * of item autofade in length (seconds, -1 for no autofade set)
		D_FADEOUTLEN_AUTO : double * of item autofade out length (seconds, -1 for no autofade set)
		C_FADEINSHAPE : int * to fadein shape, 0=linear, ...
		C_FADEOUTSHAPE : int * to fadeout shape
		I_GROUPID : int * to group ID (0 = no group)
		I_LASTY : int * to last y position in track (readonly)
		I_LASTH : int * to last height in track (readonly)
		I_CUSTOMCOLOR : int * : custom color, windows standard color order (i.e. RGB(r,g,b)|0x100000). if you do not |0x100000, then it will not be used (though will store the color anyway)
		I_CURTAKE : int * to active take
		IP_ITEMNUMBER : int, item number within the track (read-only, returns the item number directly)
		F_FREEMODE_Y : float * to free mode y position (0..1)
		F_FREEMODE_H : float * to free mode height (0..1)
		]]
		--[[
		
		-- MODIFY INFOS
		value_set = value_get -- Prepare value output
		
		-- SET INFOS
		reaper.SetMediaItemInfo_Value(item, "D_VOL", value_set) -- Set the value to the parameter
	end -- ENDLOOP through selected items
	--]]

	-- LOOP THROUGH SELECTED TAKES
	--[[
	selected_items_count = reaper.CountSelectedMediaItems(0)
	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
		take = reaper.GetActiveTake(item) -- Get the active take
		if take ~= nil then -- if ==, it will work on "empty"/text items only
			-- GET INFOS
			value_get = reaper.GetMediaItemTakeInfo_Value(take, "D_VOL") -- Get the value of a the parameter
			--[[
			D_STARTOFFS : double *, start offset in take of item
			D_VOL : double *, take volume
			D_PAN : double *, take pan
			D_PANLAW : double *, take pan law (-1.0=default, 0.5=-6dB, 1.0=+0dB, etc)
			D_PLAYRATE : double *, take playrate (1.0=normal, 2.0=doublespeed, etc)
			D_PITCH : double *, take pitch adjust (in semitones, 0.0=normal, +12 = one octave up, etc)
			B_PPITCH, bool *, preserve pitch when changing rate
			I_CHANMODE, int *, channel mode (0=normal, 1=revstereo, 2=downmix, 3=l, 4=r)
			I_PITCHMODE, int *, pitch shifter mode, -1=proj default, otherwise high word=shifter low word = parameter
			I_CUSTOMCOLOR : int *, custom color, windows standard color order (i.e. RGB(r,g,b)|0x100000). if you do not |0x100000, then it will not be used (though will store the color anyway)
			IP_TAKENUMBER : int, take number within the item (read-only, returns the take number directly)
			]]
			--[[
			-- MODIFY INFOS
			value_set = value_get -- Prepare value output
			-- SET INFOS
			reaper.SetMediaItemTakeInfo_Value(take, "D_VOL", value_set) -- Set the value to the parameter
		end -- ENDIF active take
	end -- ENDLOOP through selected items
	--]]

	-- LOOP TRHOUGH SELECTED TRACKS
	--[[
	selected_tracks_count = reaper.CountSelectedTracks(0)
	for i = 0, selected_tracks_count-1  do
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i
		--GET INFOS
		value_get = reaper.GetMediaTrackInfo_Value(track, "B_MUTE")
		--[[
		B_MUTE : bool * : mute flag
		B_PHASE : bool * : invert track phase
		IP_TRACKNUMBER : int : track number (returns zero if not found, -1 for master track) (read-only, returns the int directly)
		I_SOLO : int * : 0=not soloed, 1=solo, 2=soloed in place
		I_FXEN : int * : 0=fx bypassed, nonzero = fx active
		I_RECARM : int * : 0=not record armed, 1=record armed
		I_RECINPUT : int * : record input. <0 = no input, 0..n = mono hardware input, 512+n = rearoute input, 1024 set for stereo input pair. 4096 set for MIDI input, if set, then low 5 bits represent channel (0=all, 1-16=only chan), then next 5 bits represent physical input (31=all, 30=VKB)
		I_RECMODE : int * : record mode (0=input, 1=stereo out, 2=none, 3=stereo out w/latcomp, 4=midi output, 5=mono out, 6=mono out w/ lat comp, 7=midi overdub, 8=midi replace
		I_RECMON : int * : record monitor (0=off, 1=normal, 2=not when playing (tapestyle))
		I_RECMONITEMS : int * : monitor items while recording (0=off, 1=on)
		I_AUTOMODE : int * : track automation mode (0=trim/off, 1=read, 2=touch, 3=write, 4=latch
		I_NCHAN : int * : number of track channels, must be 2-64, even
		I_SELECTED : int * : track selected? 0 or 1
		I_WNDH : int * : current TCP window height (Read-only)
		I_FOLDERDEPTH : int * : folder depth change (0=normal, 1=track is a folder parent, -1=track is the last in the innermost folder, -2=track is the last in the innermost and next-innermost folders, etc
		I_FOLDERCOMPACT : int * : folder compacting (only valid on folders), 0=normal, 1=small, 2=tiny children
		I_MIDIHWOUT : int * : track midi hardware output index (<0 for disabled, low 5 bits are which channels (0=all, 1-16), next 5 bits are output device index (0-31))
		I_PERFFLAGS : int * : track perf flags (&1=no media buffering, &2=no anticipative FX)
		I_CUSTOMCOLOR : int * : custom color, windows standard color order (i.e. RGB(r,g,b)|0x100000). if you do not |0x100000, then it will not be used (though will store the color anyway)
		I_HEIGHTOVERRIDE : int * : custom height override for TCP window. 0 for none, otherwise size in pixels
		D_VOL : double * : trim volume of track (0 (-inf)..1 (+0dB) .. 2 (+6dB) etc ..)
		D_PAN : double * : trim pan of track (-1..1)
		D_WIDTH : double * : width of track (-1..1)
		D_DUALPANL : double * : dualpan position 1 (-1..1), only if I_PANMODE==6
		D_DUALPANR : double * : dualpan position 2 (-1..1), only if I_PANMODE==6
		I_PANMODE : int * : pan mode (0 = classic 3.x, 3=new balance, 5=stereo pan, 6 = dual pan)
		D_PANLAW : double * : pan law of track. <0 for project default, 1.0 for +0dB, etc
		P_ENV : read only, returns TrackEnvelope *, setNewValue= B_SHOWINMIXER : bool * : show track panel in mixer -- do not use on master
		B_SHOWINTCP : bool * : show track panel in tcp -- do not use on master
		B_MAINSEND : bool * : track sends audio to parent
		B_FREEMODE : bool * : track free-mode enabled (requires UpdateTimeline() after changing etc)
		C_BEATATTACHMODE : char * : char * to one char of beat attached mode, -1=def, 0=time, 1=allbeats, 2=beatsposonly
		F_MCP_FXSEND_SCALE : float * : scale of fx+send area in MCP (0.0=smallest allowed, 1=max allowed)
		F_MCP_SENDRGN_SCALE : float * : scale of send area as proportion of the fx+send total area (0=min allow, 1=max)
		]]
		--[[
		-- ACTIONS
	end -- ENDLOOP through selected tracks
	--]]
	--]]

	-- LOOP THROUGH REGIONS
	--[[
	i=0
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
		if iRetval >= 1 then
			if bIsrgnOut == true then
				-- ACTION ON REGIONS HERE
			end
			i = i+1
		end
	until iRetval == 0
	--]]
	--]]

	-- LOOP TRHOUGH FX - by HeDa
	--[[
	tracks_count = reaper.CountTracks(0)
	for i = 0, tracks_count-1  do -- loop for all tracks
			
		track = reaper.GetTrack(0, i)	-- which track
		track_FX_count = reaper.TrackFX_GetCount(tracki) -- count number of FX instances on the track
		
		for i = 0, track_FX_count-1  do,	-- loop for all FX instances on each track
			-- ACTIONS
					
		end -- ENDLOOP FX loop
	end -- ENDLOOP tracks loop
	--]]
	--]]
	
	-- YOUR CODE ABOVE

	reaper.Undo_EndBlock("My action", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

function Init()
	-- START
	debug_table = {}

	-- Variables to be initiated
	init_sel_items = {}
	init_sel_tracks = {}
	init_sel_regions = {}


	getSelectedItems(init_sel_items)
	getSelectedTracks(init_sel_tracks)
	getSelectedRegions(init_sel_regions)


	reaper.PreventUIRefresh(1)

	reaper.ShowConsoleMsg("Executing...")

	-- SaveView()
	-- SaveCursorPos()
	-- SaveLoopTimesel()
	-- SaveSelectedItems(init_sel_items_table)
	-- SaveSelectedTracks(init_sel_tracks_table)

	main()

	--SaveView()
	--SaveCursorPos()
	--SaveLoopTimesel()
	--SaveSelectedItems(init_sel_items_table)
	--SaveSelectedTracks(init_sel_tracks_table)

	reaper.PreventUIRefresh(-1)

	reaper.UpdateArrange()

	reaper.ShowConsoleMsg("\nDone!")

end

-- LUA 
-- STRING FUNC

function stringIsEmpty(s)
	return s == nil or s == ""
end


function stringIsIndex(s)
	if string.find (s, "") then 
		local i,j = string.find (s, "")
		return string.sub(s, i, j)
	else
		return nil
	end
end


function stringSplitIndex(inputstr, sep)
  if sep == nil then
      sep = "%s"
  end

  if string.find(inputstr,sep) == nil then 
    return {inputstr}
  else
    ti_str = {} 
    local i = 1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(ti_str, i,str)
      i = i + 1
    end
    return ti_str
  end
end


function stringSplit (inputstr, sep)
  if sep == nil then
      sep = "%s"
  end

  if string.find(inputstr,sep) == nil then 
    return {inputstr}
  else
    t_str = {} 
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t_str, str)
    end
    return t_str
  end
end


-- LUA 
-- TABLE FUNC
function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end


function tableLength(T)
  local cnt = 0
  for _ in pairs(T) do cnt = cnt + 1 end
  return cnt
end


-- REAPER
-- ITEM FUNC

function getSelectedItems(t_item)
    item_t = {}
    for i = 0, reaper.CountSelectedMediaItems(0)-1  do
        table.insert(t_item, reaper.GetSelectedMediaItem(0, i)) 
    end
end

function snapItem2Item(item1, item2)
	value_set = reaper.GetMediaItemInfo_Value(item1, "D_POSITION")
	reaper.SetMediaItemInfo_Value(item2, "D_POSITION", value_set)
end


function getItemName(item)
	local take = reaper.GetActiveTake(item) 
	local take_name = reaper.GetTakeName(take)
	return take_name
end



-- REAPER
-- REGION FUNC
function getSelectedRegions(t_region)
    i=0
    repeat
        retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0,i)
        if retval >= 1 then
            if isrgn == true then
                table.insert(t_region, markrgnindexnumber) 
            end
            i = i+1
        end
    until retval == 0
end


-- REAPER
-- TRACK FUNC
function getSelectedTracks(t_track)
    for i = 0, reaper.CountSelectedTracks(0)-1 do
        table.insert(t_track, reaper.GetTrack(0, i)) 
    end
end



-- REAPER
-- VOLUME FUNC
function Volume2DB (volumevalue)
	return 20*(math.log(volumevalue, 10))
end


function DB2Volume (dbvalue)
	return math.exp(logvalue*0.115129254)	
end


-- REAPER
-- DEBUG FUNC
function Log(msg) 
	reaper.ShowConsoleMsg(tostring(msg).."\n")
end



if not preset_file_init then
	Init()
end


-- Embass function optimized for lua by amagalma
--  binary + linear search
function get_media_items_in_time_range2(track, start_time, end_time)
  local item_count = reaper.CountTrackMediaItems(track) - 1
  if item_count == -1 or start_time == end_time then return end
  local function get_next_item_index(track, time_position) -- item index or nil
    local last_item_start = reaper.GetMediaItemInfo_Value(reaper.GetTrackMediaItem(track, item_count), "D_POSITION")
    if time_position > last_item_start then return end
    local L, R = 0, item_count
    while L < R do
      local i = (L+R) >> 1
      local item_start = reaper.GetMediaItemInfo_Value(reaper.GetTrackMediaItem(track, i), "D_POSITION")
      if item_start < time_position then L = i + 1
      else R = i end
    end
    return L
  end
  local media_items, index = {}, nil
  local track_media_items_count = item_count
  local item_index = get_next_item_index(track, start_time) -- binary search
  if not item_index then index = track_media_items_count else index = item_index - 1 end
  local n = 0
  for i = 0, index do
    local media_item = reaper.GetTrackMediaItem(track, i)
    if reaper.GetMediaItemInfo_Value(media_item,"D_POSITION")+reaper.GetMediaItemInfo_Value(media_item,"D_LENGTH")>start_time then
      n = n + 1
      media_items[n] = media_item
    end
  end
  if item_index then
    local item_index2 = get_next_item_index(track, end_time) -- binary search
    if not item_index2 then item_index2 = item_count
    else item_index2 = item_index2 - 1 end
    n = #media_items
    for i = item_index, item_index2 do
      n = n + 1
      media_items[n] = reaper.GetTrackMediaItem(track, i)
    end
  end
  return media_items
end