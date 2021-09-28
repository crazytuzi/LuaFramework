function PSOpenXiakeJiuguan()
end


function RegProt(prot, func)
	if prot == nil then
		print("unknown prot:"..tostring(prot));
	else
		prot.process = func;
	end
end

RegProt(SOpenXiakeJiuguan, PSOpenXiakeJiuguan);
