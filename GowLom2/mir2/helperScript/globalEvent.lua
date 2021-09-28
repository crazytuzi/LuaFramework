GuideAlways = {
	"firstLogin",
	"learnSkill",
	"backHome",
	"diyPanel"
}

function main(evt)
	if evt == "firstLogin" then
		print("globalEvent firstLogin")
		mod.newbee(evt)
	elseif evt == "learnSkill" then
		mod.newbee(evt)
	elseif evt == "backHome" then
		mod.newbee(evt)
	elseif evt == "diyPanel" then
		mod.newbee(evt)
	end

	return 
end

return 
