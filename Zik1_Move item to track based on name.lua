--[[
 * ReaScript Name: Move item to track based on name
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
 * v1.0 (2022-12-25) init
 * v1.1 (2022-01-18) clean up 
--]]
 
-- USER CONFIG AREA ---------------------------------------------

-- Do you want a pop up to appear ?
CONFIG_UI_popup = true -- true/false

-- Define here your default user input variables values
common_part = "XXX" -- y/n for whether select master mix
variate_part = "A;B" -- Variate part in item name, separated by ;
reference_part = "A" -- common part in item name

-----------------------------------------------------------------

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  local track_match_table = {}
  local item_match_track_table = {}
  local item_match_item_table_reference = {}
  local item_match_item_table_toChange = {}

	for i = 0, selected_tracks_count-1  do
		-- GET THE TRACK
		local cur_track = reaper.GetSelectedTrack(0, i) -- Get selected track i
		local  _, cur_track_name = reaper.GetTrackName( cur_track )
		local cur_track_name_table = stringSplitIndex(cur_track_name,"_")


		local common_part_match =false
		local vairate_part_match = false
		local tmp_k = ""

		for k, v in pairs(cur_track_name_table) do
		  if v == common_part then
		  	common_part_match = true
		  end

		  if tableContains(variate_table,v) then
		  	variate_part_match = true
		  	tmp_k = v
		  end
		end

		if common_part_match and variate_part_match then 
			track_match_table[tmp_k] = cur_track
		end
	end

	-- EVALUTATE ITEMS
  for i = 0, selected_items_count-1 do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		common_part_match = false
		vairate_part_match = false
		local tmp_variateIndex = ""
		local tmp_keyIndex = ""


		-- GET INFOS
		local item_name = getItemName(item)

		local alt_version = string.find(item_name, "ALT")

		local cur_item_name_table = stringSplitIndex(item_name,"_")


		for k, v in pairs(cur_item_name_table) do
		  if v == common_part then
		  	common_part_match = true
		  end

		  if tableContains(variate_table,v) then
		  	variate_part_match = true
		  	tmp_variateIndex = v
		  end

		  if stringIsEmpty(tmp_keyIndex) then
		  	tmp_keyIndex = stringIsKeyIndex(v)
		  end

		end
		
		-- Save results
		if common_part_match and variate_part_match then 

			item_match_track_table[item] = track_match_table[tmp_variateIndex]

		 	if tmp_keyIndex ~= "" or tmp_keyIndex ~= nil then
	 			local unique_index = cur_item_name_table[1] .. cur_item_name_table[2] .. tmp_keyIndex

			 	if tmp_variateIndex == reference_part and alt_version == nil then 
			 		item_match_item_table_reference[unique_index] = item
			 	else
			 		if item_match_item_table_toChange[unique_index] then 
			 			table.insert(item_match_item_table_toChange[unique_index],item)
			 		else 
			 			item_match_item_table_toChange[unique_index] = {}
			 			table.insert(item_match_item_table_toChange[unique_index],item)
			 		end
			 	end
	 		end

		end
	end


	for x, y in pairs(item_match_item_table_toChange) do
		for _, yy in pairs(y) do 
			if item_match_item_table_reference[x] then
				snapItem2Item(item_match_item_table_reference[x], yy)
			end
		end
	end


	-- set tracks
	for m, n in pairs(item_match_track_table) do
		reaper.MoveMediaItemToTrack(m, n)
	end

  reaper.Undo_EndBlock("Action Done", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

function Init()
	-- START
	debug_array = {}

	-- GET COMMON VALUES
	selected_tracks_count = reaper.CountSelectedTracks(0)
	selected_items_count = reaper.CountSelectedMediaItems(0)

	if CONFIG_UI_popup == true then 

		defaultvals_csv = common_part .. "," .. variate_part .. "," .. reference_part

		retval, retvals_csv = reaper.GetUserInputs("Move Item to Track", 3, "Common Part, Variation Part(sep by ;), Snap to", defaultvals_csv)

		if retval then -- if user compelte the fields

			-- retrieve user input info
			user_input_table = stringSplit(retvals_csv, ",")
			common_part = user_input_table[1]
			variate_part = user_input_table[2]
			reference_part = user_input_table[3]
			variate_table = {}

			if string.find(variate_part, ";") then
				local sep = ";"
			  for str in string.gmatch(variate_part, "([^"..sep.."]+)") do
			  	table.insert(variate_table, str)
				end
			end

			if tableLength(variate_table) > selected_tracks_count then
				Log("wrong number of variation or track selected, abort!")
				return
			end

			reaper.PreventUIRefresh(1)

			reaper.ShowConsoleMsg("Select all regions...")

			--SaveView()
			--SaveCursorPos()
			--SaveLoopTimesel()
			--SaveSelectedItems(init_sel_items_table)
			--SaveSelectedTracks(init_sel_tracks_table)

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


	else 

		reaper.PreventUIRefresh(1)

		reaper.ShowConsoleMsg("Select all regions...")

		log("no proper input, abort!")

		reaper.PreventUIRefresh(-1)

		reaper.UpdateArrange()

		reaper.ShowConsoleMsg("\nDone!")

	end 

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
    local sep = "%s"
  end

  if string.find(inputstr,sep) == nil then 
    return {inputstr}
  else
    local t_str = {} 
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
    local item_t = {}
    for i = 0, reaper.CountSelectedMediaItems(0)-1  do
        table.insert(t_item, reaper.GetSelectedMediaItem(0, i)) 
    end
end

function snapItem2Item(item1, item2)
	local value_set = reaper.GetMediaItemInfo_Value(item1, "D_POSITION")
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
    local i = 0
    repeat
        local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0,i)
        if retval >= 1 then
            if isrgn == true then
                table.insert(t_region, markrgnindexnumber) 
            end
            i = i + 1
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

--[[
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
]]

--[[ <==== INITIAL SAVE AND RESTORE ----- 

-- LOOP AND TIME SELECTION
-- SAVE INITIAL LOOP AND TIME SELECTION
function SaveLoopTimesel()
  init_start_timesel, init_end_timesel = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
  init_start_loop, init_end_loop = reaper.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
end

-- RESTORE INITIAL LOOP AND TIME SELECTION
function RestoreLoopTimesel()
  reaper.GetSet_LoopTimeRange(1, 0, init_start_timesel, init_end_timesel, 0)
  reaper.GetSet_LoopTimeRange(1, 1, init_start_loop, init_end_loop, 0)
end

-- CURSOR
-- SAVE INITIAL CURSOR POS
function SaveCursorPos()
  init_cursor_pos = reaper.GetCursorPosition()
end

-- RESTORE INITIAL CURSOR POS
function RestoreCursorPos()
  reaper.SetEditCurPos(init_cursor_pos, false, false)
end

-- VIEW
--[[ SAVE INITIAL VIEW
function SaveView()
  start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end


-- RESTORE INITIAL VIEW
function RestoreView()
  reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end 


-- SAVE INITIAL TRACKS SELECTION
local function SaveSelectedTracks (table)
  for i = 0, reaper.CountSelectedTracks(0)-1 do
    table[i+1] = reaper.GetSelectedTrack(0, i)
  end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
  UnselectAllTracks()
  for _, track in ipairs(table) do
    reaper.SetTrackSelected(track, true)
  end
end

-- <==== INITIAL SAVE AND RESTORE ----- ]]

if not preset_file_init then
	Init()
end
