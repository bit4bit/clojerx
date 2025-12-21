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
(ns Howto (:gen-class))

(defn -main [& args])
  (let [node (OtpNode. "Howto")
        mbox (.createMBox node)]
      ; Mandatory same name as Elixir Module
      (.registerName mbox "Howto")
      ;; process {:link, _ref, from} link using (.link mbox from)
      ;; ....
      )
```

Start the Elixir with snames.
```bash
iex --sname demo -S mix
```

```iex
iex(demo@tere)> {:ok, howto} = Howto.start_link()
iex(demo@tere)> Howto.call(howto, :any, [1, 2, 3])
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `clojerx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:clojerx, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/clojerx>.
