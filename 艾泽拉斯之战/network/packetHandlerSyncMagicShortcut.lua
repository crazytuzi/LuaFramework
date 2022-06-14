function SyncMagicShortcutHandler( __optional_flag__shortcuts,  shortcuts )
	
	for i=1, 16 do
		if __optional_flag__shortcuts:isSetbit(i-1) then
			for k,v in ipairs(shortcuts[i]['shortcuts']) do
				PLAN_CONFIG.setMagicPlan(i-1, k, v);
			end
		end
	end
	--dump(shortcuts);
	--dump(PLAN_CONFIG);
end
