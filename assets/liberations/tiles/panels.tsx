<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.10" tiledversion="1.12.2" name="panels" tilewidth="50" tileheight="30" tilecount="48" columns="8" objectalignment="top">
 <tileoffset x="0" y="1"/>
 <grid orientation="isometric" width="64" height="32"/>
 <properties>
  <property name="Layer" type="int" value="10"/>
 </properties>
 <image source="panels.png" width="400" height="180"/>
 <tile id="0">
  <animation>
   <frame tileid="0" duration="1000"/>
   <frame tileid="8" duration="500"/>
   <frame tileid="16" duration="500"/>
   <frame tileid="24" duration="1000"/>
   <frame tileid="16" duration="500"/>
   <frame tileid="8" duration="500"/>
  </animation>
 </tile>
 <tile id="1">
  <animation>
   <frame tileid="1" duration="1000"/>
   <frame tileid="9" duration="500"/>
   <frame tileid="17" duration="500"/>
   <frame tileid="25" duration="1000"/>
   <frame tileid="17" duration="500"/>
   <frame tileid="9" duration="500"/>
  </animation>
 </tile>
 <tile id="2">
  <objectgroup draworder="index" id="2">
   <object id="1" x="-4" y="3" width="35" height="35"/>
  </objectgroup>
  <animation>
   <frame tileid="2" duration="500"/>
   <frame tileid="10" duration="500"/>
   <frame tileid="18" duration="500"/>
   <frame tileid="26" duration="500"/>
   <frame tileid="18" duration="500"/>
   <frame tileid="10" duration="500"/>
  </animation>
 </tile>
 <tile id="3">
  <objectgroup draworder="index" id="2">
   <object id="1" x="-4" y="3" width="35" height="35"/>
  </objectgroup>
  <animation>
   <frame tileid="3" duration="320"/>
   <frame tileid="11" duration="320"/>
   <frame tileid="19" duration="320"/>
   <frame tileid="27" duration="320"/>
   <frame tileid="19" duration="320"/>
   <frame tileid="11" duration="320"/>
  </animation>
 </tile>
 <tile id="4">
  <objectgroup draworder="index" id="2">
   <object id="1" x="-4" y="3" width="35" height="35"/>
  </objectgroup>
  <animation>
   <frame tileid="4" duration="200"/>
   <frame tileid="12" duration="200"/>
   <frame tileid="20" duration="200"/>
   <frame tileid="28" duration="200"/>
   <frame tileid="36" duration="200"/>
   <frame tileid="44" duration="133"/>
   <frame tileid="36" duration="200"/>
   <frame tileid="28" duration="200"/>
   <frame tileid="20" duration="200"/>
   <frame tileid="12" duration="200"/>
  </animation>
 </tile>
 <tile id="5">
  <objectgroup draworder="index" id="2">
   <object id="1" x="-4" y="3" width="35" height="35"/>
  </objectgroup>
  <animation>
   <frame tileid="5" duration="2000"/>
   <frame tileid="13" duration="100"/>
   <frame tileid="21" duration="33"/>
   <frame tileid="29" duration="17"/>
   <frame tileid="37" duration="17"/>
  </animation>
 </tile>
 <tile id="6">
  <objectgroup draworder="index" id="2">
   <object id="1" x="-4" y="3" width="35" height="35"/>
  </objectgroup>
  <animation>
   <frame tileid="6" duration="2000"/>
   <frame tileid="14" duration="100"/>
   <frame tileid="22" duration="33"/>
   <frame tileid="30" duration="17"/>
   <frame tileid="38" duration="17"/>
  </animation>
 </tile>
 <tile id="7">
  <objectgroup draworder="index" id="2">
   <object id="1" x="-4" y="3" width="35" height="35"/>
  </objectgroup>
  <animation>
   <frame tileid="7" duration="2000"/>
   <frame tileid="15" duration="100"/>
   <frame tileid="23" duration="33"/>
   <frame tileid="31" duration="17"/>
   <frame tileid="39" duration="17"/>
  </animation>
 </tile>
</tileset>
