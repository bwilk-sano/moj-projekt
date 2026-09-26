# Sample notes so a fresh app has something to show. Safe to run many times.
[
  [ "Pomysł na weekend", "Wypad w Bieszczady: Tarnica o świcie, potem pierogi w Wetlinie. Sprawdzić prognozę w czwartek." ],
  [ "Lista zakupów", "Kawa ziarnista\nAwokado ×3\nMąka orkiszowa\nCoś słodkiego (bez przesady)" ],
  [ "Notatki ze spotkania", "Ustalić zakres MVP do piątku. Logowanie gotowe, teraz design. Następnie: notatki przypisane do użytkownika." ],
  [ "Książki do przeczytania", "Solaris — Lem\nPiknik na skraju drogi — Strugaccy\nDesigning Data-Intensive Applications" ],
  [ "Cytat dnia", "Najpierw zrób, żeby działało. Potem, żeby było dobrze. Na końcu, żeby było szybko." ]
].each do |title, body|
  Note.find_or_create_by!(title: title) { |note| note.body = body }
end
