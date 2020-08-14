Global("Locales", {})

function getLocale()
	return Locales[common.GetLocalization()] or Locales["eng"]
end

--------------------------------------------------------------------------------
-- Russian
--------------------------------------------------------------------------------

Locales["rus"]={}
Locales["rus"]["lineM"]="���-�� ����������"
Locales["rus"]["lineR"]="���-�� ���������"
Locales["rus"]["lineB"]="���-�� �������������"
Locales["rus"]["lineCrit"]="���-�� �����"
Locales["rus"]["lineDiff"]="����� ������� ��:"
Locales["rus"]["resM"]="�� ���������"
Locales["rus"]["resR"]="�� ���������"
Locales["rus"]["resB"]="�� ���������"
Locales["rus"]["resDiff"]="�� ���������"
Locales["rus"]["resCrit"]="�� ���������"
Locales["rus"]["resType1"]="�� ���������"
Locales["rus"]["resType2"]="�� ���������"
Locales["rus"]["resType3"]="�� ���������"
Locales["rus"]["resType4"]="�� ���������"
Locales["rus"]["calcButton1"]="����� 1"
Locales["rus"]["calcButton2"]="����� 2"
Locales["rus"]["desc"]="������������ ������ ������������ ����������� ����������, �������������, ��������� � �����. ������������� ���� �� ��� ��� ������� � ��������� �� ������� ������. ������ ����������, ��������������� ����� �� ��� �����(��� ��� ������� ������ �������������). ��� �������� 20 ������."
Locales["rus"]["amuletInfo"]="*������ �� �������� ������� ���������, ��� �� � ������� ���������� ����������: "
Locales["rus"]["useShop"]="��������� � ����� (+100)"
Locales["rus"]["useOrden"]="��������� � ������� (+100�)"
Locales["rus"]["amountOfR"]="������� ��������� (0-100) : "
Locales["rus"]["useAlhim"]="��������� � ������� (+50)"
Locales["rus"]["useEatR"]="��������� � ���� (+25�)"
Locales["rus"]["useGuildCrit"]="��������� � �������� (+40�)"
Locales["rus"]["useDoblest"]="��������� � ���������"
Locales["rus"]["useOrnament"]="��������� � ����������� (+48� +48�)"
Locales["rus"]["type1"]="���� ����������� �����(%):"
Locales["rus"]["type2"]="���� ���������� �����(%):"
Locales["rus"]["type3"]="���� ������������� �����(%):"
Locales["rus"]["type4"]="���� ���������� �����(%):"
Locales["rus"]["lvlOfArt"]="������� ��������� (0-10) : "
--------------------------------------------------------------------------------
-- English
--------------------------------------------------------------------------------

Locales["eng"]={}
Locales["eng"]["lineM"]="Skill count"
Locales["eng"]["lineR"]="Determination count"
Locales["eng"]["lineB"]="Number of ruthlessness"
Locales["eng"]["lineCrit"]="Amount of luck"
Locales["eng"]["lineDiff"]="Better current on:"
Locales["eng"]["resM"]="Not counted"
Locales["eng"]["resR"]="Not counted"
Locales["eng"]["resB"]="Not counted"
Locales["eng"]["resDiff"]="Not counted"
Locales["eng"]["resCrit"]="Not counted"
Locales["eng"]["resType1"]="Not counted"
Locales["eng"]["resType2"]="Not counted"
Locales["eng"]["resType3"]="Not counted"
Locales["eng"]["resType4"]="Not counted"
Locales["eng"]["calcButton1"]="Method 1"
Locales["eng"]["calcButton2"]="Method 2"
Locales["eng"]["desc"]="An optimal balance of skill, ruthlessness, determination and luck is calculated. Only those that are already invested in the currently specified ones are balanced. The selection of domination and swiftness lies with you (they are for each class are individual). The calculation step is 20 stats. "
Locales["eng"]["amuletInfo"]="* Based on the quality of the amulet, it is believed that it adds skill on average: "
Locales["eng"]["useShop"]="Calculate with shop (+100)"
Locales["eng"]["useOrden"]="Count with the order (+100?)"
Locales["eng"]["amountOfR"]="Determination level (0-100) : "
Locales["eng"]["useAlhim"]="Count with alchem (+50)"
Locales["eng"]["useEatR"]="Calculate with food (+25?)"
Locales["eng"]["useGuildCrit"]="Calculate with guild (+40o)"
Locales["eng"]["useDoblest"]="Calculate with valor"
Locales["eng"]["useOrnament"]="Count with ornaments (+48i +48o)"
Locales["eng"]["type1"]="Percentage of Physical damage(%):"
Locales["eng"]["type2"]="Proportion of Elemental damage(%):"
Locales["eng"]["type3"]="Divine Damage Percentage(%):"
Locales["eng"]["type4"]="Share of Natural damage(%):"
Locales["eng"]["lvlOfArt"]="Triquetra level (0-10) : "
