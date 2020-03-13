-- yeet me the buck outta this world
local function hex_to_dec(hex_str) return tonumber(hex_str,16) end
local function hex_to_rgb(hex_str)
    local hex = string.sub(hex_str,2)
    if string.len(hex) == 3 then -- https://gist.github.com/fernandohenriques/12661bf250c8c2d8047188222cab7e28
        return ( hex_to_dec(string.sub(hex,1,1)*17)/255 ),( hex_to_dec(string.sub(hex,2,2)*17)/255 ),( hex_to_dec(string.sub(hex,3,3)*17)/255 ),1
    else -- https://gist.github.com/jasonbradley/4357406
        return ( hex_to_dec(string.sub(hex,1,2))/255 ),( hex_to_dec(string.sub(hex,3,4))/255 ),( hex_to_dec(string.sub(hex,5,6))/255 ),1
    end
end

function PlayerColor( pn )
	if pn == PLAYER_1 then return DifficultyColor(3) end
	if pn == PLAYER_2 then return DifficultyColor(1) end
	return "1,1,1,1"
end

function DefaultColor()
	if Color() > 9 then return Color() end
	return '0'..Color()
end
	
function Color(c)
	if not Profile(0) then return 1 end
	if not Profile(0).Love then Profile(0).Love = { Color = 1 } end
	if c then Profile(0).Love.Color = c end
	return Profile(0).Love and Profile(0).Love.Color or 1
end

function FeetPosition()
	y = 13 + 120 - 120*Color()
	return y
end

function IconY()
	y = 260 - 40*Color()
	return y
end

function IconCrop(self)
	self:croptop((Color()-1)/12)
	self:cropbottom(1-Color()/12)
end

function DifficultyColor( dc )
	if dc == DIFFICULTY_EDIT then return "#c3c5d4" end
	if CONSTMELODY.Chegg then return "#fedc00" end
	local color = CONSTMELODY.Pony.Pony()
	if color == 1  then return "#d5a4e6" end -- Twilight Sparkle
	if color == 2  then return "#ffc360" end -- Applejack
	if color == 3  then return "#fbf7ad" end -- Fluttershy
	if color == 4  then return "#ebeff2" end -- Rarity
	if color == 5  then return "#f4b6cf" end -- Pinkie Pie
	if color == 6  then return "#9fdaf8" end -- Rainbow Dash
	if color == 7  then return "#f5f59b" end -- Apple Bloom
	if color == 8  then return "#fbbb64" end -- Scootaloo
	if color == 9  then return "#eeecef" end -- Sweetie Belle
	if color == 10 then return "#f9f7fa" end -- Princess Celestia
	if color == 11 then return "#314a8d" end -- Princess Luna
	if color == 12 then return "#f9c6e5" end -- Princess Cadence
	return "#c3c5d4" -- Derpy
end

function BubbleColorRGB ( pn )
	if GAMESTATE:IsPlayerEnabled( pn ) then
		local steps = GAMESTATE:GetCurrentSteps( pn )
		if not steps then return 1,1,1,0 end
		steps = steps:GetDifficulty()
		if steps == DIFFICULTY_EDIT	then return 0.71,0.72,0.73,1 end
		return ColorRGB(steps-2)
	end
	return 1,1,1,1
end

function DifficultyColorRGB( n ) if n < 5 then return ColorRGB( n - 2 ) else return 0.71,0.72,0.73,1 end end

function ColorRGB ( n,forcecolor )
	if CONSTMELODY.Chegg then return hex_to_rgb("#fedc00") end
	local color = (n and type(n) == 'number' and forcecolor) and n or CONSTMELODY.Pony.Pony()
	if color == 1  then return hex_to_rgb("#d5a4e6") end -- Twilight Sparkle
	if color == 2  then return hex_to_rgb("#ffc360") end -- Applejack
	if color == 3  then return hex_to_rgb("#fbf7ad") end -- Fluttershy
	if color == 4  then return hex_to_rgb("#ebeff2") end -- Rarity
	if color == 5  then return hex_to_rgb("#f4b6cf") end -- Pinkie Pie
	if color == 6  then return hex_to_rgb("#9fdaf8") end -- Rainbow Dash
	if color == 7  then return hex_to_rgb("#f5f59b") end -- Apple Bloom
	if color == 8  then return hex_to_rgb("#fbbb64") end -- Scootaloo
	if color == 9  then return hex_to_rgb("#eeecef") end -- Sweetie Belle
	if color == 10 then return hex_to_rgb("#f9f7fa") end -- Princess Celestia
	if color == 11 then return hex_to_rgb("#314a8d") end -- Princess Luna
	if color == 12 then return hex_to_rgb("#f9c6e5") end -- Princess Cadence
	return hex_to_rgb("#c3c5d4")
end

-- Get a color to show text on top of difficulty frames.
function ContrastingDifficultyColor( dc )
	if dc == DIFFICULTY_BEGINNER	then return "#000000" end
	if dc == DIFFICULTY_EASY		then return "#000000" end
	if dc == DIFFICULTY_MEDIUM		then return "#000000" end
	if dc == DIFFICULTY_HARD		then return "#000000" end
	if dc == DIFFICULTY_CHALLENGE	then return "#000000" end
	if dc == DIFFICULTY_EDIT		then return "#000000" end
	return "1,1,1,1"
end

function TextOnColor (n)
	local color = Color() + 12
	if n then color = color + n end
	color = math.mod(color-1,12)+1
	if color == 9 then return 0,0,0,1 end
	if color == 10 then return 0,0,0,1 end
	if color == 11 then return 0,0,0,1 end
	if color == 12 then return 0,0,0,1 end
	return 1,1,1,1
end

function BubbleColorText ( pn )
	if not GAMESTATE:IsPlayerEnabled( pn ) then return 1,1,1,1 end
	
	local steps = GAMESTATE:GetCurrentSteps( pn )
	if not steps then return 1,1,1,0 end
	if steps == DIFFICULTY_EDIT	then return 0,0,0,1 end

	if CONSTMELODY.Chegg then return 0,0,0,1 end
	
	local color = CONSTMELODY.Pony.Pony()
	if color == 1  then return 1,1,1,1 end -- Twilight Sparkle
	if color == 2  then return 1,1,1,1 end -- Applejack
	if color == 3  then return 0,0,0,1 end -- Fluttershy
	if color == 4  then return 0,0,0,1 end -- Rarity
	if color == 5  then return 1,1,1,1 end -- Pinkie Pie
	if color == 6  then return 1,1,1,1 end -- Rainbow Dash
	if color == 7  then return 0,0,0,1 end -- Apple Bloom
	if color == 8  then return 1,1,1,1 end -- Scootaloo
	if color == 9  then return 0,0,0,1 end -- Sweetie Belle
	if color == 10 then return 0,0,0,1 end -- Princess Celestia
	if color == 11 then return 1,1,1,1 end -- Princess Luna
	if color == 12 then return 0,0,0,1 end -- Princess Cadence

	return 1,1,1,1
end