con meta = fn (db :: Type, widget :: Type) =>
              {Nam : string,
               Show : db -> xbody,
               Widget : nm :: Name -> xml form [] [nm = widget],
               WidgetPopulated : nm :: Name -> db -> xml form [] [nm = widget],
               Parse : widget -> db,
               Inject : sql_injectable db}

fun default [t] (sh : show t) (rd : read t) (inj : sql_injectable t) name : meta (t, string) =
    {Nam = name,
     Show = txt,
     Widget = fn [nm :: Name] => <xml><textbox{nm}/></xml>,
     WidgetPopulated = fn [nm :: Name] n =>
                          <xml><textbox{nm} value={show n}/></xml>,
     Parse = readError,
     Inject = _}

val int = default
val float = default
val string = default
fun bool name = {Nam = name,
                 Show = txt,
                 Widget = fn [nm :: Name] => <xml><checkbox{nm}/></xml>,
                 WidgetPopulated = fn [nm :: Name] b =>
                                      <xml><checkbox{nm} checked={b}/></xml>,
                 Parse = fn x => x,
                 Inject = _}

fun textarea name = {Nam = name,
                     Show = cdata,
                     Widget = fn [nm :: Name] => <xml><br/><textarea{nm} rows={10} cols={80}/></xml>,
                     WidgetPopulated = fn [nm :: Name] s => <xml><br/>
                       <textarea{nm} rows={10} cols={80}>{[s]}</textarea>
                     </xml>,
                     Parse = fn s => s,
                     Inject = _}

fun allWidgets [ts ::: {(Type * Type)}] (r : $(map meta ts)) (fl : folder ts) =
    foldR [meta] [fn ts :: {(Type * Type)} => xml form [] (map snd ts)]
          (fn [nm :: Name] [t :: (Type * Type)] [rest :: {(Type * Type)}]
                           [[nm] ~ rest] (col : meta t) (acc : xml form [] (map snd rest)) => <xml>
                             <b>{[col.Nam]}</b>: {col.Widget [nm]}<br/>
                             {useMore acc}
                           </xml>)
          <xml/>
          [_] fl r