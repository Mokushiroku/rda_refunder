mRDA = {} -- Leave This


/*
Addon created by Moku, Mokushiroku.xyz
Inspired by Vloxan's RDM Refunder
*/


--Config Section


mRDA.AuthedRanks = { --Only use this if staff are unable to open the menu.
	"",
}


/*
Add ranks like this:

mRDA.AuthedRanks = {
	"owner",
	"mod", 
}

Always remember the "" and , at the end
*/


/*

DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING

*/


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
for k,v in pairs(mRDA.StartUp) do
	MsgC( Color(k * math.Round(255 / #mRDA.StartUp, 0), 255,255), v .. "\n")
end


-- Net Messages
util.AddNetworkString( "mrda_refund" )
util.AddNetworkString( "mrda_weps" )
util.AddNetworkString( "mrda_authed" )


/*
Non-Hooked Functions
*/


function mRDA.GiveWeps( plyid, arrestid )
	local ply = Player( plyid )
	if !( ply:IsValid() ) then return end
	if ply.storedWeps == nil then return end
	
	for k,v in pairs( ply.storedWeps[arrestid] ) do
		ply:Give( v )
	end
end


/*
Hooked Functions
*/


-- Called post-arrest, to store the players weps and arrest count etc.
function mRDA.GetArrestedWeapons( ply )
	ply.arrestAmount = ply.arrestAmount + 1
	ply.storedWeps[ply.arrestAmount] = {}
	
	for _,weps in ipairs( ply:GetWeapons() ) do
		table.insert( ply.storedWeps[ply.arrestAmount], weps:GetClass() ) -- Must get the class because the entity is removed when the player is arrested
	end
end
hook.Add( "playerArrested", "GetArrestedWeapons", mRDA.GetArrestedWeapons )


function mRDA.AuthPlayer( ply )
	if ply:IsAdmin() || table.HasValue( mRDA.AuthedRanks, ply:GetUserGroup() ) then
		net.Start( "mrda_authed" )
		net.Send( ply )
	end
end
hook.Add( "PlayerSpawn", "Authenticator", mRDA.AuthPlayer )


function mRDA.CreateInitialVars( ply )
	--print( "Creating Vars for "..ply:Nick() )
	
	ply.arrestAmount = 0
	ply.storedWeps = {}
end
hook.Add( "PlayerInitialSpawn", "CreateInitialVars", mRDA.CreateInitialVars )


/*
Net Messages, admin checks included
*/


net.Receive( "mrda_refund", function( len, ply )
	if !( ply:IsAdmin() ) && !( table.HasValue( mRDA.AuthedRanks, ply:GetUserGroup() ) ) then return end -- Prevent skids who think net messages are exploits.
	local PlyToRefund = net.ReadInt( 32 ) --Not sending anything else so bitcount doesnt exactly matter.
	local ArrestToRefund = net.ReadInt( 31 )
	
	if PlyToRefund != nil then -- dont wanna throw errors
		mRDA.GiveWeps( PlyToRefund, ArrestToRefund )
	end
end )


net.Receive( "mrda_weps", function( len, sender )
	if !( sender:IsAdmin() ) && !( table.HasValue( mRDA.AuthedRanks, sender:GetUserGroup() ) ) then return end
	
	local plyid = net.ReadInt( 32 )
	local ply = Player( plyid )
	if !( ply:IsValid() ) then return end
	
	net.Start( "mrda_weps" )
		net.WriteInt( ply.arrestAmount, 32 )
	net.Send( sender )
	
end )

