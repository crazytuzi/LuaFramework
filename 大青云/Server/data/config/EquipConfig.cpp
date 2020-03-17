

#include "EquipConfig.h"
#include "LuaReader.h"
#include <cassert>

namespace mars
{
	int EquipConfig::Load(const char* path,const char* name)
	{
		mars_utils::LuaReader reader;
		reader.LoadFile(path,name);

		std::vector<std::string>& vTableKeys = reader.GetTablekeys();
		for (size_t i = 0; i < vTableKeys.size(); ++i)
		{
			SEquipConfig v;

			const char* key = vTableKeys[i].c_str();
			v.id = reader.ReadInteger(key,"id");
			v.name = reader.ReadString(key,"name");
			v.comment = reader.ReadString(key,"comment");
			v.main = reader.ReadInteger(key,"main");
			v.quality = reader.ReadInteger(key,"quality");
			v.priority = reader.ReadInteger(key,"priority");
			v.vocation = reader.ReadInteger(key,"vocation");
			v.can_use = reader.ReadBoolean(key,"can_use");
			v.icon = reader.ReadString(key,"icon");
			v.groupId = reader.ReadInteger(key,"groupId");
			v.extraGroupId = reader.ReadInteger(key,"extraGroupId");
			v.null = reader.ReadInteger(key,"null");
			v.pos = reader.ReadInteger(key,"pos");
			v.sex = reader.ReadInteger(key,"sex");
			v.bind = reader.ReadInteger(key,"bind");
			v.level = reader.ReadInteger(key,"level");
			v.needlevel = reader.ReadInteger(key,"needlevel");
			v.step = reader.ReadInteger(key,"step");
			v.baseAttr = reader.ReadString(key,"baseAttr");
			v.sell = reader.ReadBoolean(key,"sell");
			v.destroy = reader.ReadBoolean(key,"destroy");
			v.price = reader.ReadInteger(key,"price");
			v.guarantee = reader.ReadInteger(key,"guarantee");
			v.proid = reader.ReadInteger(key,"proid");
			v.drop_value = reader.ReadInteger(key,"drop_value");
			v.log = reader.ReadInteger(key,"log");
			v.assin_super = reader.ReadString(key,"assin_super");
			v.decompose = reader.ReadString(key,"decompose");
			v.assin_supernew = reader.ReadString(key,"assin_supernew");
			v.star = reader.ReadInteger(key,"star");
			v.des_group = reader.ReadInteger(key,"des_group");
			v.group_bind = reader.ReadInteger(key,"group_bind");
			v.need_attr = reader.ReadString(key,"need_attr");

			m_vConfigs.push_back(v);
		}
		return 0;
	}

	int EquipConfig::Size()
	{
		return m_vConfigs.size();
	}

	SEquipConfig& EquipConfig::Get(int i)
	{
		if (i >= 0 && i < (int)m_vConfigs.size())
		{
			return m_vConfigs[i];
		}
		static SEquipConfig tmp;
		return tmp;
	}
}
