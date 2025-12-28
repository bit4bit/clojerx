(ns Clojure
  (:import [com.ericsson.otp.erlang OtpNode OtpErlangObject OtpErlangTuple]))

(defn init
  "Connect to Erlang EPMD and do handshake of initialization"
  [module_name]
  (let [node (OtpNode. module_name)
        mbox (.createMbox node)]
    (.registerName mbox module_name)
    (let [o (.receive mbox 5000)
          tuple ^OtpErlangTuple o
          action (.elementAt tuple 0)
          action_ref (.elementAt tuple 1)
          action_reply_pid (.elementAt tuple 2)
          atom_fun_name (.elementAt tuple 3)
          fun_name (str atom_fun_name)]
      (if (not= (str action) "clojerx")
        (throw (Exception. (str "Invalid clojerx action: got " action))))
      (if (not= fun_name "link")
        (throw (Exception. (str "Fail initialization first message must be `link` received" fun_name))))
      (.link mbox action_reply_pid)
      (let [reply (OtpErlangTuple. (into-array OtpErlangObject [action action_ref atom_fun_name]))]
        (.send mbox action_reply_pid reply)
        [node mbox])
  )))
