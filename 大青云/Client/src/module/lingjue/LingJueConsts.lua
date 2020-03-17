--[[
灵诀 constants
haohu
2016年1月22日11:33:33
]]

_G.LingJueConsts = {}

LingJueConsts.maxLevel = nil
function LingJueConsts:GetMaxLevel()
	if not self.maxLevel then
		local tid--[[ 任意取 ]]
		local level = 0
		for _, cfg in pairs(t_lingjue) do
			if not tid then
				tid = cfg.lingjue_id
			elseif tid == cfg.lingjue_id then
				level = math.max(level, cfg.lingjue_lv)
			end
		end
		self.maxLevel = level
	end
	return self.maxLevel
end