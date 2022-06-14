-- 选择魔法

function packetHandlerChooseMagic()
	local tempArrayCount = 0;
	local chooses = {};

-- 选择列表
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		chooses[i] = ParseMagicChoose();
	end

	ChooseMagicHandler( chooses );
end

