(ns MinimalExampleClojerx
  (:require [Clojure :as Clojerx])
  (:gen-class))
(import '(com.ericsson.otp.erlang OtpNode OtpErlangTuple OtpErlangList OtpErlangLong OtpErlangObject))

(defn sum [a b] (+ a b))

(def dispatch
  {"sum" sum})

(defn -main [& args]
  (let [[node mbox] (Clojerx/init "MinimalExampleClojerx")]
    (loop []
      (println "Waiting for message upa...")
      (let [o (.receive mbox)
            tuple ^OtpErlangTuple o
            action (.elementAt tuple 0)
            action_ref (.elementAt tuple 1)
            action_reply_pid (.elementAt tuple 2)
            atom_fun_name (.elementAt tuple 3)
            list_fun_args (.elementAt tuple 4)
            fun_name (str atom_fun_name)]
          (let [fun_arg_0 (.longValue (.elementAt list_fun_args 0))
          fun_arg_1 (.longValue (.elementAt list_fun_args 1))
            result (apply (dispatch fun_name) [fun_arg_0 fun_arg_1])
                reply (OtpErlangTuple. (into-array OtpErlangObject [action action_ref atom_fun_name (OtpErlangLong. result)]))]
            (.send mbox action_reply_pid reply)))
        (recur))))
