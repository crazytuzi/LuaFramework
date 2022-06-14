function SyncShipHandler( ships )
	-- ≤‚ ‘ ˝æ›

	for k,v in ipairs(ships) do
		print("syncShipHandler index: "..v.index.." level: "..v.level);

		shipData.shiplist[v.index+1]:setLevel(v.level);
		shipData.shiplist[v.index+1]:setRemouldLevel(v.remouldLevel);
				
		for kp, vp in ipairs(v.plans) do
			PLAN_CONFIG.setShipsPlan(kp-1, v.index+1, vp);
		end
	end
	
	--dump(PLAN_CONFIG);
end
