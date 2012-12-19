require 'rubygems'
require 'bing_translator'

spanish = File.read('backend/scraped.example/song_lyrics/2508/1805126').split("\n").reject { |line| line.include?('..') && false }.join(" | \n")

#puts spanish

translator = BingTranslator.new(
  'vocabincontext',
  'CBbm/uev8lIADCKa6ejSq3evAoHA+wkN7QWxB1SVA/k=')

#p spanish

english = translator.translate spanish, :from => 'es', :to => 'en'

puts english


#He estao durmiendo a dos metros bajo tierra
#Y ahora he decidio dormir sobre la tierra
#He pasao tanto tiempo lamentando lo que no entendia
#
#Que ahora prefiero que me den la clara del dia
#He pasao tanto tiempo lamentando lo que no entendia
#Que ahora prefiero que me den la clara del dia
#
#No...no no no...no no no no...no mas llorá
#No...no no no...no no no no...no mas llorá(mas
#Aaaaaaaaa...
#
#Empieza mi viaje en la carretera
#Por fin camino solaEn mi casita con ruedas
#El tiempo será pa mi lo que yo quiera que sea
#Nunca un muro,
#nunca un muro, solo lo que yo quiera
#Recorro montañas, desiertos, ciudades enteras
#No tengo ninguna prisa, paro, donde quiera
#La musica que llevo será mi compañera
#Aaaaaaa....Mmmm.....Aaaaaaaa.....
#
#Aprendi a escuchar la noche
#No pienso enterrar mis dolores
#Pa que duelan menos
#Voy a sacarlos de dentro, cerca del mar
#Pa que se los lleve el viento
#Pa que se los lleve el
#que se los lleve el viento
#Hoy, pa mi la burra grande
#
#Ande, que ande o no ande
#Que la quiero para cosé
#A que me importune este cante
#
#No, que tengo yo en mi soledad
#Ciento de canciones tarareá
#Empeza in acabaA punto, a punto, a punto de que
#Noo, que tengo yo en mi soledad,
#ciento de canciones tarareáEmpeza in acaba
#
#A punto a punto a punto de estallar
#Que tengo yo en mi soledad
#Ciento de canciones tarareá
#Empeza in acaba
#A punto a punto a punto de estallar
#Hay algunas que nadie ama
#Quiero que comprendan porque son pa mi na ma
#
#Pa mi corazon
#Pa mi pensamiento
#Pa mi reflesion
#Paa mii
#No se cuando volveré
#No se donde llegaré
#No se que me encontrare
#Ni me importa
#No se cuando volveré
#No se donde llegaré
#No se que me encontrare
#Ni me importa
#<i><b>Bebe</b></i>

# ----------------------------------
#
#I estão sleeping two meters underground and now I have decided to stay on earth I have spend so much time regretting what they do not understand that I now prefer that it give me clear day I spend so much time lamenting what they do not understand that I now prefer to give me the day not clear...no no no... not not not not... no more cries do not...no no no... not not not not... no more llorá(mas Aaaaaaaaa...)
#
#Begins my journey on the road finally road solaEn mi casita wheeled time will be pa my what I want to be never a wall, never a wall, only what I want travel mountains, deserts, and entire cities I have no hurry, I stop, wherever the music that I will be my companion Aaaaaaa...Mmmm.....Aaaaaaaa.....
#
#Aprendi a escuchar la noche
#No pienso enterrar mis dolores
#Pa que duelan menos
#Voy a sacarlos de dentro, cerca del mar
#Pa que se los lleve el viento
#Pa que se los lleve el
#que se los lleve el viento
#Hoy, pa mi la burra grande
#
#Ande, que ande o no ande
#Que la quiero para cosé
#A que me importune este cante
#
#No, que tengo yo en mi soledad
#Ciento de canciones tarareá
#Empeza in acabaA punto, a punto, a punto de que
#Noo, que tengo yo en mi soledad,
#ciento de canciones tarareáEmpeza in acaba
#
#A punto a punto a punto de estallar
#Que tengo yo en mi soledad
#Ciento de canciones tarareá
#Empeza in acaba
#A punto a punto a punto de estallar
#Hay algunas que nadie ama
#Quiero que comprendan porque son pa mi na ma
#
#Pa mi corazon
#Pa mi pensamiento
#Pa mi reflesion
#Paa mii
#No se cuando volveré
#No se donde llegaré
#No se que me encontrare
#Ni me importa
#No se cuando volveré
#No se donde llegaré
#No se que me encontrare
#Ni me importa
#<i><b>Bebe</b></i>
#
