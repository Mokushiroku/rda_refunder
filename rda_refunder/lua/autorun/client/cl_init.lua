--cl side

local mRDA = {}
mRDA.Authed = false

-- Fade Startup Message
mRDA.StartUp = {
	"",
	"d s   sb d ss.  d ss    d s.   ",
	"S  S S S S    b S   ~o  S  ~O  ",
	"S   S  S S    P S     b S   `b ",
	"S      S S sS'  S     S S sSSO ",
	"S      S S   S  S     P S    O ",
	"S      S S    S S    S  S    O ",
	"P      P P    P P ss    P    P ",
	"",
}

--Splits the color in half serverside, clientside creates a nice fade effect.
for k,v in pairs( mRDA.StartUp ) do
	MsgC( Color( k * math.Round( 255 / #mRDA.StartUp, 0), 255, 255 ), v .. "\n" )
end


function mRDA.CreateMenu()
	if !mRDA.Authed then chat.AddText( color_white, "[mRDA] ", Color( 255, 126, 136 ), "You are not authenticated!") return end
	
	mRDA.PlyArrestTable = {}
	local PlyIDTable = {}
	local SelectedPly = nil
	local SelectedArrest = nil
	
	mRDA.Frame = vgui.Create( "DFrame" )
	mRDA.Frame:SetSize( 540, 240 )
	mRDA.Frame:SetTitle( "Moku's RDA Refunder" )
	mRDA.Frame:SetScreenLock( true )
	mRDA.Frame:MakePopup()
	mRDA.Frame:Center()
	
	mRDA.PlayerList = vgui.Create( "DComboBox", mRDA.Frame ) 
	mRDA.PlayerList:SetSize( 200, 40 )
	mRDA.PlayerList:SetPos( 270 - 100, 60 - 20 )
	mRDA.PlayerList:SetValue( "Players" )
	for _,v in ipairs( player.GetAll() ) do
		mRDA.PlayerList:AddChoice( v:Nick() )
		table.insert( PlyIDTable, v )
	end
	
	mRDA.ArrestList = vgui.Create( "DComboBox", mRDA.Frame ) 
	mRDA.ArrestList:SetSize( 200, 40 )
	mRDA.ArrestList:SetPos( 270 - 100, 115 - 20 )
	mRDA.ArrestList:SetValue( "Arrests" )
	
	mRDA.Refund = vgui.Create( "DButton", mRDA.Frame )
	mRDA.Refund:SetSize( 200, 60 )
	mRDA.Refund:SetText( "Refund Player" )
	mRDA.Refund:SetPos( 270 - 100, 240 - 90 )
	
	-- Painting Functions, using a forloop seemed irrelavant
	function mRDA.Frame:Paint( w, h ) 
		surface.SetDrawColor( color_white )
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor( color_black )
		surface.DrawRect( 0, 0, w, 25 )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	
	-- loopy loop
	mRDA.MenuTable = { mRDA.Refund, mRDA.ArrestList, mRDA.PlayerList }
	for k,v in pairs( mRDA.MenuTable ) do
		function v:Paint( w, h ) 
			surface.SetDrawColor( color_white )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( color_black )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
	end
	
	-- Other Functions
	function mRDA.PlayerList.OnSelect( panel, index, value )
		if ( PlyIDTable[index]:IsBot() ) then return end
		SelectedPly = ( PlyIDTable[index]:UserID() )
		net.Start( "mrda_weps" )
			net.WriteInt( SelectedPly, 32 )
		net.SendToServer()
	end
	
	function mRDA.ArrestList.OnSelect( panel, index, value )
		SelectedArrest = index
	end
	
	function mRDA.Refund.DoClick()
		if SelectedPly == nil || SelectedArrest == nil then return end
		
		net.Start( "mrda_refund" )
			net.WriteInt( SelectedPly, 32 )
			net.WriteInt( SelectedArrest, 32 )
		net.SendToServer()
	end
end


function mRDA.MenuHook( ply, text, teamchat, dead )
	if ply != LocalPlayer() || teamchat then return end
	
	if text == "!mrda" then
		mRDA.CreateMenu()
	end
end
hook.Add( "OnPlayerChat", "mRDAMenuHook", mRDA.MenuHook )


net.Receive( "mrda_authed", function()
	if !mRDA.Authed then
		chat.AddText( color_white, "[mRDA] ", Color( 126, 255, 136 ), "You have been Authenticated!" )
	end
	
	mRDA.Authed = true
end )


net.Receive( "mrda_weps", function()
	mRDA.ArrestList:Clear()
	mRDA.ArrestList:SetText( "Arrests" )
	
	local Arrested = net.ReadInt( 32 )
	
	if Arrested == nil then return end
	for i = 1, Arrested do
		mRDA.ArrestList:AddChoice( i )
	end
end )

