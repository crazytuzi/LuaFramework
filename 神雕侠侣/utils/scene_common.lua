scene_util = {}

function scene_util.GetPetNameColor(colour)
	local cfg = knight.gsp.pet.GetCPetXueMaiConfigTableInstance():getRecorder(colour);
	local ret = string.format("[colrect='tl:%s tr:%s bl:%s br:%s']", cfg.colourrgb, cfg.colourrgb, cfg.colourrgb, cfg.colourrgb);
	return ret;
end

function scene_util.GetPetColour(colour)
	local cfg = knight.gsp.pet.GetCPetXueMaiConfigTableInstance():getRecorder(colour);
    
    local ret = "ffffffff"
    if cfg then
        ret = string.format("%s", cfg.colourrgb)
    end
    
	return ret;
end

return scene_util;
