<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.10" tiledversion="1.12.2" name="conveyor" tilewidth="64" tileheight="35" tilecount="6" columns="3">
 <tileoffset x="1" y="2"/>
 <image source="conveyor.png" width="192" height="70"/>
 <tile id="0" type="Conveyor">
  <properties>
   <property name="Direction" value="Down Right"/>
   <property name="Sound Effect" value="/server/assets/sounds/conveyor.ogg"/>
  </properties>
  <animation>
   <frame tileid="0" duration="133"/>
   <frame tileid="1" duration="133"/>
   <frame tileid="2" duration="133"/>
  </animation>
 </tile>
 <tile id="3" type="Conveyor">
  <properties>
   <property name="Direction" value="Up Left"/>
   <property name="Sound Effect" value="/server/assets/sounds/conveyor.ogg"/>
  </properties>
  <animation>
   <frame tileid="3" duration="133"/>
   <frame tileid="4" duration="133"/>
   <frame tileid="5" duration="133"/>
  </animation>
 </tile>
</tileset>
