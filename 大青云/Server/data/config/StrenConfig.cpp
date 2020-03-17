

#include "StrenConfig.h"
#include "LuaReader.h"
#include <cassert>

namespace mars
{
	int StrenConfig::Load(const char* path,const char* name)
	{
		mars_utils::LuaReader reader;
		reader.LoadFile(path,name);

		std::vector<std::string>& vTableKeys = reader.GetTablekeys();
		for (size_t i = 0; i < vTableKeys.size(); ++i)
		{
			SStrenConfig v;

			const char* key = vTableKeys[i].c_str();
			v.level = reader.ReadInteger(key,"level");
			v.type = reader.ReadInteger(key,"type");
			v.itemId = reader.ReadInteger(key,"itemId");
			v.itemNum = reader.ReadInteger(key,"itemNum");
			v.yuanbaoNum = reader.ReadInteger(key,"yuanbaoNum");
			v.gold = reader.ReadInteger(key,"gold");
			v.maxVal = reader.ReadInteger(key,"maxVal");
			v.weights = reader.ReadString(key,"weights");
			v.rand1 = reader.ReadString(key,"rand1");
			v.rand2 = reader.ReadString(key,"rand2");
			v.extremeRate = reader.ReadInteger(key,"extremeRate");
			v.openstar = reader.ReadString(key,"openstar");
			v.keepItem = reader.ReadInteger(key,"keepItem");
			v.keepNum = reader.ReadInteger(key,"keepNum");
			v.DropRate = reader.ReadInteger(key,"DropRate");
			v.DropWeight1 = reader.ReadInteger(key,"DropWeight1");
			v.DropWeight2 = reader.ReadInteger(key,"DropWeight2");
			v.DropWeight3 = reader.ReadInteger(key,"DropWeight3");
			v.DropWeight4 = reader.ReadInteger(key,"DropWeight4");

			m_vConfigs.push_back(v);
		}
		return 0;
	}

	int StrenConfig::Size()
	{
		return m_vConfigs.size();
	}

	SStrenConfig& StrenConfig::Get(int i)
	{
		if (i >= 0 && i < (int)m_vConfigs.size())
		{
			return m_vConfigs[i];
		}
		static SStrenConfig tmp;
		return tmp;
	}
}
