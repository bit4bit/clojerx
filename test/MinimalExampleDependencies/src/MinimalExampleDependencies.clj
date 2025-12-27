(ns MinimalExampleDependencies
  (:require [java-time.api :as t])
  (:gen-class))
(import '(com.ericsson.otp.erlang OtpNode OtpErlangTuple OtpErlangList OtpErlangLong OtpErlangObject))

(defn first-month-of-year [year]
  (t/as (t/local-date year) :month-of-year))

(def dispatch
  {"first-month-of-year" first-month-of-year})

(defn -main [& args]
  (let [node (OtpNode. "MinimalExampleDependencies")
        mbox (.createMbox node)]
    (.registerName mbox "MinimalExampleDependencies")
    (loop []
      (println "Waiting for message...")
      (let [o (.receive mbox)
            tuple ^OtpErlangTuple o
            action (.elementAt tuple 0)
            action_ref (.elementAt tuple 1)
            action_reply_pid (.elementAt tuple 2)
            atom_fun_name (.elementAt tuple 3)
            list_fun_args (.elementAt tuple 4)
            fun_name (str atom_fun_name)
]
        (if (not= (str action) "clojerx")
          (throw (Exception. (str "Invalid action: " action " expected clojerx"))))
        (println "Received message" fun_name)
        (case (str atom_fun_name)
          "link" (do
                   (.link mbox action_reply_pid)
                   (let [reply (OtpErlangTuple. (into-array OtpErlangObject [action action_ref atom_fun_name]))]
                     (.send mbox action_reply_pid reply)))
          (let [fun_arg_0 (.longValue (.elementAt list_fun_args 0))
            result (apply first-month-of-year [fun_arg_0])
                reply (OtpErlangTuple. (into-array OtpErlangObject [action action_ref atom_fun_name (OtpErlangLong. result)]))]
            (.send mbox action_reply_pid reply)))
        (recur)))))
