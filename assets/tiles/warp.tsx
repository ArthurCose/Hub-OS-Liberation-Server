<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.10" tiledversion="1.12.2" name="warp" tilewidth="64" tileheight="32" tilecount="9" columns="3" objectalignment="top">
 <image source="warp.png" width="192" height="96"/>
 <tile id="0">
  <properties>
   <property name="Layer" type="int" value="5"/>
  </properties>
 </tile>
 <tile id="1">
  <properties>
   <property name="Layer" type="int" value="5"/>
  </properties>
  <objectgroup draworder="index" id="2">
   <object id="1" x="13" y="1" width="38" height="22">
    <ellipse/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="1" duration="266"/>
   <frame tileid="2" duration="266"/>
   <frame tileid="3" duration="266"/>
   <frame tileid="4" duration="266"/>
   <frame tileid="5" duration="266"/>
   <frame tileid="4" duration="266"/>
   <frame tileid="3" duration="266"/>
   <frame tileid="2" duration="266"/>
  </animation>
 </tile>
 <tile id="6">
  <properties>
   <property name="Layer" type="int" value="10"/>
  </properties>
 </tile>
</tileset>
