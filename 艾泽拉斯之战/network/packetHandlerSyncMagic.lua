function SyncMagicHandler( __optional_flag__magics,  magics )
	for i=1, 256 do
		if __optional_flag__magics:isSetbit(i-1) then
			local magicInstance = dataManager.kingMagic:getMagic(i);
			print("syncMagicHandler id:"..i.." exp "..magics[i]);
			magicInstance:setExp(magics[i]);
		end
	end

end
