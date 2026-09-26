# Moj Projekt

Notatnik w Ruby on Rails 8: rejestracja, logowanie i notatki (CRUD) z nowoczesnym, responsywnym UI w trybie ciemnym i jasnym.
Całe środowisko developerskie działa w [Devboxie](https://www.jetify.com/devbox), więc nic nie instaluje się globalnie w systemie.

| Warstwa      | Technologia                                                      |
| ------------ | ---------------------------------------------------------------- |
| Język        | Ruby 3.3 (z Nix, przez Devbox)                                   |
| Framework    | Rails 8.1                                                        |
| Baza danych  | SQLite 3 (`storage/*.sqlite3`)                                   |
| Frontend     | Hotwire (Turbo + Stimulus), Importmap, Propshaft, czysty CSS     |
| Auth         | Wbudowany generator Rails 8 (`has_secure_password`, bcrypt)      |
| i18n         | `rails-i18n`, domyślny język `pl`, strefa czasowa `Warsaw`       |
| Jakość       | Minitest, RuboCop (rails-omakase), Brakeman, bundler-audit       |

---

## Wymagania wstępne

Przed pierwszą komendą `devbox …` w systemie muszą być **tylko Devbox i Nix**. Wszystko inne (Ruby, SQLite, kompilator C, macOS SDK dla gemów natywnych, gemy) dostarcza projekt.

| Co                        | Po co                                            | Jak sprawdzić              |
| ------------------------- | ------------------------------------------------ | -------------------------- |
| macOS (Apple Silicon lub Intel) albo Linux x86_64/arm64 | Obsługiwane platformy Nix. Na Windows użyj WSL2. | `uname -sm`                |
| `curl` i `bash`           | Instalator Devboxa                               | są w systemie domyślnie    |
| Uprawnienia administratora (`sudo`) | Jednorazowo: instalacja Nix tworzy `/nix` (na macOS osobny wolumin APFS), użytkowników `nixbld` i demona `nix-daemon` | — |
| **Nix** (testowane: 2.35) | Menedżer pakietów, z którego Devbox bierze Rubiego i resztę | `nix --version`   |
| **Devbox** (testowane: 0.18) | Środowisko projektu (`devbox.json`)              | `devbox version`           |
| Git                       | Tylko do sklonowania repozytorium                | `git --version`            |
| ~1,5 GB wolnego miejsca   | ~0,8 GB w `/nix/store` + ~0,2 GB gemów w `.devbox/` + zapas | `df -h /`       |
| Internet przy pierwszym `setup` | Pobieranie z `cache.nixos.org` i `rubygems.org` | —                     |

### Instalacja (jednorazowo)

1. **Devbox:**

   ```bash
   curl -fsSL https://get.jetify.com/devbox | bash
   ```

2. **Nix:** jeśli go nie masz, Devbox przy pierwszym uruchomieniu spróbuje go zainstalować i poprosi o hasło `sudo`. Pewniej jest zainstalować go wcześniej ręcznie (tym instalatorem był instalowany Nix, na którym testowano projekt):

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   Po instalacji Nix **otwórz nowy terminal**, żeby w `PATH` pojawiło się `nix`.

3. **Sprawdzenie:**

   ```bash
   devbox version && nix --version
   ```

**Niepotrzebne:** Ruby, rbenv/asdf, Homebrew, SQLite, Node.js ani Xcode / Command Line Tools. Clang i macOS SDK do kompilacji gemów natywnych (np. bcrypt) też przychodzą z Nix. Jeśli masz w systemie innego Rubiego, nie przeszkadza, bo w `devbox shell` / `devbox run` zawsze wygrywa wersja z projektu.

---

## Szybki start

Z katalogu projektu:

```bash
devbox run setup    # Bundler, gemy, baza danych (idempotentne, można odpalać wielokrotnie)
devbox run server   # http://127.0.0.1:3000
```

Otwórz http://127.0.0.1:3000, załóż konto przez „Załóż konto” i gotowe.
Przykładowe notatki doładujesz komendą `devbox run -- bin/rails db:seed`.

> Pierwsze uruchomienie (i każde po zmianie `devbox.json`) trwa około minuty, bo Nix buduje środowisko. Kolejne są natychmiastowe.

---

## Jak działa izolacja środowiska

Devbox czyta [`devbox.json`](devbox.json) i udostępnia pakiety z Nix **tylko w obrębie tego projektu**:

- **Ruby, SQLite, libyaml** leżą we współdzielonym `/nix/store`, niewidoczne poza `devbox shell` / `devbox run`.
- **Gemy** (Rails, Bundler itd.) instalują się do `.devbox/virtenv/ruby` (`GEM_HOME`), nie do `~/.gem`.
- **Systemowy Ruby i Homebrew** pozostają nietknięte.

Sprzątanie wszystkiego: `rm -rf .devbox`, a opcjonalnie `nix store gc`, żeby zwolnić miejsce w `/nix/store`.

Wersje pakietów są zablokowane w [`devbox.lock`](devbox.lock). Commituj go razem z `devbox.json`.

---

## Codzienna praca

Wszystkie komendy uruchamiaj przez Devbox: albo pojedynczo przez `devbox run …`, albo raz wejdź do powłoki `devbox shell` i dalej pracuj normalnie (`bin/rails …`).

| Komenda                           | Co robi                                                               |
| --------------------------------- | --------------------------------------------------------------------- |
| `devbox run setup`                | Instaluje właściwy Bundler i gemy, przygotowuje bazę, czyści logi     |
| `devbox run server`               | Serwer deweloperski na `127.0.0.1:3000`                               |
| `devbox run test`                 | Testy (`bin/rails test`)                                              |
| `devbox run ci`                   | Pełny lokalny CI: RuboCop, audyty bezpieczeństwa, Brakeman, testy     |
| `devbox run console`              | Konsola Rails                                                         |
| `devbox run -- <dowolna komenda>` | Dowolna komenda w środowisku projektu, np. `devbox run -- bin/rails routes` |

Przydatne:

```bash
devbox run -- bin/rails db:migrate          # po dodaniu migracji
devbox run -- bin/rails db:seed             # przykładowe notatki (bez duplikatów)
devbox run -- bin/rails db:reset            # UWAGA: kasuje bazę deweloperską i odtwarza ją z seeds
devbox run -- bin/rubocop -a                # autopoprawki stylu
```

**Przed pushem odpal `devbox run ci`.** To ta sama sekwencja kroków, którą zdefiniowano w [`config/ci.rb`](config/ci.rb).

---

## Struktura projektu

Najważniejsze miejsca (reszta to standardowy układ Rails):

```
app/
├── controllers/
│   ├── concerns/authentication.rb   # logika sesji: require_authentication, start_new_session_for …
│   ├── sessions_controller.rb       # logowanie / wylogowanie
│   ├── registrations_controller.rb  # zakładanie konta
│   ├── passwords_controller.rb      # reset hasła mailem
│   └── notes_controller.rb          # CRUD notatek (HTML + JSON)
├── models/
│   ├── user.rb                      # has_secure_password, walidacje, normalizacja e-maila
│   ├── session.rb                   # jedna sesja = jedno zalogowane urządzenie
│   ├── current.rb                   # Current.session / Current.user (per request)
│   └── note.rb
├── views/
│   ├── layouts/application.html.erb # layout aplikacji (nagłówek, toasty)
│   ├── layouts/auth.html.erb        # layout ekranów logowania (split screen)
│   └── shared/                      # _head, _flash, _errors, _brand, _theme_toggle
├── helpers/application_helper.rb    # icon(:name), accent_for(record), avatar_for(user)
├── javascript/controllers/          # Stimulus: flash, filter, theme
└── assets/stylesheets/application.css  # cały design system w jednym pliku
config/locales/pl.yml                # nazwy atrybutów i poprawki polskich tłumaczeń
db/seeds.rb                          # przykładowe notatki
devbox.json                          # pakiety i skrypty środowiska
```

---

## Uwierzytelnianie

Kod pochodzi z generatora `bin/rails generate authentication` (Rails 8), rozszerzonego o rejestrację.

- **Hasła** są hashowane bcryptem (`has_secure_password`), mają minimum 8 i maksimum 72 znaki (limit bcrypta).
- **Sesje** są zapisywane w tabeli `sessions` (z IP i user agentem). Przeglądarka dostaje tylko podpisane ciasteczko `session_id` (`httponly`, `SameSite=Lax`).
- **Rate limiting:** maksimum 10 prób logowania i rejestracji na 3 minuty.
- **E-mail** jest normalizowany (`strip` + `downcase`) i unikalny, także na poziomie indeksu w bazie.

**Domyślnie wszystko wymaga zalogowania**, bo `ApplicationController` dołącza concern `Authentication`. Żeby udostępnić akcję gościom:

```ruby
class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[ home ]
end
```

Zalogowany użytkownik jest dostępny jako `Current.user`, zarówno w kontrolerach, jak i w widokach. W widokach działa też helper `authenticated?`.

### Reset hasła w developmencie

SMTP nie jest skonfigurowany, więc maile nie wychodzą. Zamiast tego użyj podglądu maili:

- http://127.0.0.1:3000/rails/mailers/passwords_mailer/reset — gotowy mail resetu z działającym linkiem.

---

## Frontend

Bez Node.js i bez kroku budowania. Importmap serwuje JS, Propshaft serwuje CSS prosto z `app/assets`.

### Design system

Cały wygląd siedzi w [`app/assets/stylesheets/application.css`](app/assets/stylesheets/application.css):

- **Tokeny** (kolory, cienie, promienie) to zmienne CSS na `:root`. Zmieniasz je w jednym miejscu.
- **Motyw ciemny i jasny:** domyślnie zgodny z systemem. Przełącznik w nagłówku ustawia `<html data-theme="…">` i zapamiętuje wybór w `localStorage`. Skrypt w `shared/_head` nakłada motyw przed pierwszym renderem, więc strona nie mruga.
- **Gotowe klasy:** `.btn` (`--primary`, `--ghost`, `--danger`, `--icon`, `--block`), `.panel`, `.field` + `.label`, `.input-icon`, `.note-card`, `.empty`, `.page-head`, `.eyebrow`, `.gradient-text`.
- **Kolor akcentu karty** pochodzi z `accent_for(record)` (`accent-0` … `accent-4`), jest stały dla danego rekordu.
- **Czcionki:** Inter i Space Grotesk z Google Fonts.

> Uwaga: atrybut `hidden` jest wymuszany regułą `[hidden] { display: none !important; }`. Bez niej klasy ustawiające `display` (np. `.note-card`) nadpisywałyby go i ukrywanie elementów z JS przestawałoby działać.

### Ikony

Ikony inline SVG w stylu Lucide, bez zewnętrznych zależności:

```erb
<%= icon :plus %>
<%= icon :trash, size: 16, css: "moja-klasa" %>   <%# rozmiar w px + dodatkowe klasy %>
```

Dostępne nazwy są w `ApplicationHelper::ICONS`. Nową ikonę dodajesz, wklejając tam ścieżki SVG z [lucide.dev](https://lucide.dev).

### Kontrolery Stimulus

| Kontroler | Gdzie                  | Co robi                                                             |
| --------- | ---------------------- | ------------------------------------------------------------------- |
| `flash`   | `shared/_flash`        | Toast chowa się sam po 4,5 s albo po kliknięciu ×                   |
| `filter`  | `notes/index`          | Filtruje karty notatek na żywo, klawisz `/` przenosi kursor do szukajki |
| `theme`   | `shared/_theme_toggle` | Przełącza motyw i zapamiętuje wybór                                 |

Nowe kontrolery wrzucasz do `app/javascript/controllers/*_controller.js`, a ładują się same (`eagerLoadControllersFrom`).

---

## Tłumaczenia

Domyślny język to polski (`config.i18n.default_locale = :pl`). Standardowe komunikaty (walidacje, daty, „5 minut temu”) dostarcza gem `rails-i18n`. W [`config/locales/pl.yml`](config/locales/pl.yml) są:

- nazwy modeli i atrybutów (dzięki nim błąd brzmi „Adres e-mail jest za krótki”, a nie „Email address …”),
- poprawki gramatyczne nadpisujące `rails-i18n` („1 minutę temu”, „nie zgadza się z polem Hasło”),
- teksty widoków z odmianą przez liczbę (`one` / `few` / `many`), np. `notes.index.count`.

Teksty z liczbą zawsze przepuszczaj przez `t(".klucz", count: n)`. Polska odmiana (1 notatka, 2 notatki, 5 notatek) nie da się obsłużyć prostym `pluralize`.

---

## Testy

```bash
devbox run test                                                        # wszystkie testy
devbox run -- bin/rails test test/controllers/notes_controller_test.rb  # jeden plik
devbox run -- bin/rails test test/controllers/notes_controller_test.rb:10  # jeden test (po linii)
```

- **Fixtures** są w `test/fixtures/`. Użytkownicy `users(:one)` i `users(:two)` mają hasło `password`, zdefiniowane w `users.yml`.
- **Logowanie w testach integracyjnych** robi helper `sign_in_as(users(:one))` (oraz `sign_out`) z `test/test_helpers/session_test_helper.rb`.
- **Testy notatek** logują się w `setup`, bo bez tego dostaną przekierowanie na stronę logowania.

---

## Baza danych

- **SQLite:** development w `storage/development.sqlite3`, testy w `storage/test.sqlite3`. Katalog `storage/` jest w `.gitignore`.
- **Schemat** jest w `db/schema.rb`. Nie edytuj go ręcznie, tylko przez migracje (`bin/rails g migration …`).
- **Produkcja:** konfiguracja przewiduje osobne bazy dla Solid Cache, Solid Queue i Solid Cable (`db/*_schema.rb`).

---

## Rozwiązywanie problemów

**Setki linii `Source locally installed gems is ignoring … because it is missing extensions` albo `warning: already initialized constant Gem::Platform::…`**
To szum z domyślnych gemów Rubiego z Nix. Jest nieszkodliwy i można go ignorować.

**`LoadError: cannot load such file -- …/bundler-2.5.22/exe/bundle`**
Bundler 2.5.x dołączony do Rubiego z Nix źle wyznacza własną ścieżkę, gdy jest wywoływany z procesu, który sam działa pod Bundlerem (np. `bin/ci` → `bin/setup`). Dlatego projekt używa nowszego Bundlera (wersja w `Gemfile.lock` → `BUNDLED WITH`), a `devbox run setup` instaluje go automatycznie. Jeśli zobaczysz ten błąd, uruchom `devbox run setup`.

**Serwer „wisi” na `Info: Ensuring packages are installed.`**
Po zmianie `devbox.json` Nix przelicza środowisko, co trwa do około minuty. Poczekaj.

**`Address already in use - bind(2) for "127.0.0.1" port 3000`**
Coś już słucha na porcie 3000. Sprawdź to przez `lsof -i :3000` albo uruchom serwer na innym porcie: `devbox run -- bin/rails server -p 3001`.

---

## Znane ograniczenia i następne kroki

- [ ] **Notatki są wspólne dla wszystkich zalogowanych.** Trzeba dodać `user_id` do `notes` i ograniczać zapytania do `Current.user.notes`.
- [ ] **Brak wysyłki maili** (SMTP / `letter_opener` w developmencie).
- [ ] **Brak konfiguracji wdrożenia.** Projekt wygenerowano z `--skip-kamal --skip-docker`, więc przed produkcją trzeba wybrać sposób hostingu.
- [ ] **Brak testów systemowych** (Capybara + przeglądarka) dla wyszukiwarki i przełącznika motywu.
