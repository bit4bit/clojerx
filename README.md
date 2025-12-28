# Clojerx

Lab experimenting with [JInterface](https://www.erlang.org/doc/apps/jinterface/jinterface_users_guide.html); the main objective is to allow the creation of extensions using Clojure/Leiningen.

*References*

* https://www.erlang.org/doc/apps/jinterface/assets/java/com/ericsson/otp/erlang/package-summary
* https://hexdocs.pm/unifex/creating_unifex_natives.html
* https://github.com/E-xyza/zigler/
* https://github.com/rusterlium/rustler

## How To Use

Define a module with `use Clojerx`.
```elixir
defmodule Howto do
  use Clojerx, otp_app: :howto
end
```

Create a clojure main (gen-class) with the same as the module.

**Howto/src/Howto.clj**
```clojure
(ns Howto (:require [Clojure :as Clojerx]) (:gen-class))

(defn -main [& args])
  (let [[node mbox] (Clojerx/init "Howto")]
      ;; ....
      )
```

Start the Elixir as distributed node (shortnames).
```bash
iex --sname demo -S mix
```

```iex
iex(demo@tere)> {:ok, howto} = Howto.start_link()
iex(demo@tere)> Howto.call(howto, :any, [1, 2, 3])
```
