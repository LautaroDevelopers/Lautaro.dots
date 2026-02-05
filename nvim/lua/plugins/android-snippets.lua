-- Android Snippets for Neovim
-- Add this to your snippets configuration or use LuaSnip

return {
  -- LuaSnip configuration for Android development
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      
      ls.add_snippets("java", {
        -- Activity snippet
        s("activity", {
          t({"public class "}), i(1, "MainActivity"),
          t({" extends AppCompatActivity {", ""}),
          t({"    @Override", ""}),
          t({"    protected void onCreate(Bundle savedInstanceState) {", ""}),
          t({"        super.onCreate(savedInstanceState);", ""}),
          t({"        setContentView(R.layout."}), i(2, "activity_main"), t({");", ""}),
          t({"        "}), i(0),
          t({"    }", "}"}),
        }),
        
        -- Fragment snippet
        s("fragment", {
          t({"public class "}), i(1, "MyFragment"),
          t({" extends Fragment {", ""}),
          t({"    @Override", ""}),
          t({"    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {", ""}),
          t({"        return inflater.inflate(R.layout."}), i(2, "fragment_my"), t({", container, false);", ""}),
          t({"    }", "}"}),
        }),
        
        -- findViewById snippet
        s("fvbi", {
          i(1, "Button"), t({" "}), i(2, "button"),
          t({" = findViewById(R.id."}), i(3, "button"), t({");"}),
        }),
        
        -- onClick listener
        s("onclick", {
          i(1, "button"), t({".setOnClickListener(new View.OnClickListener() {", ""}),
          t({"    @Override", ""}),
          t({"    public void onClick(View v) {", ""}),
          t({"        "}), i(0),
          t({"    }", "});"}),
        }),
        
        -- Toast snippet
        s("toast", {
          t({"Toast.makeText(this, \""}), i(1, "Message"),
          t({"\", Toast.LENGTH_SHORT).show();"}),
        }),
        
        -- Log snippet
        s("logd", {
          t({"Log.d(\""}), i(1, "TAG"), t({"\", \""}), i(2, "message"), t({"\");"}),
        }),
      })
      
      ls.add_snippets("kotlin", {
        -- Activity snippet
        s("activity", {
          t({"class "}), i(1, "MainActivity"),
          t({" : AppCompatActivity() {", ""}),
          t({"    override fun onCreate(savedInstanceState: Bundle?) {", ""}),
          t({"        super.onCreate(savedInstanceState)", ""}),
          t({"        setContentView(R.layout."}), i(2, "activity_main"), t({")", ""}),
          t({"        "}), i(0),
          t({"    }", "}"}),
        }),
        
        -- Fragment snippet
        s("fragment", {
          t({"class "}), i(1, "MyFragment"),
          t({" : Fragment() {", ""}),
          t({"    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {", ""}),
          t({"        return inflater.inflate(R.layout."}), i(2, "fragment_my"), t({", container, false)", ""}),
          t({"    }", "}"}),
        }),
        
        -- findViewById snippet
        s("fvbi", {
          t({"val "}), i(1, "button"), t({": "}), i(2, "Button"),
          t({" = findViewById(R.id."}), i(3, "button"), t({")"}),
        }),
        
        -- onClick listener
        s("onclick", {
          i(1, "button"), t({".setOnClickListener {", ""}),
          t({"    "}), i(0),
          t({"}"}),
        }),
        
        -- Toast snippet
        s("toast", {
          t({"Toast.makeText(this, \""}), i(1, "Message"),
          t({"\", Toast.LENGTH_SHORT).show()"}),
        }),
        
        -- Log snippet
        s("logd", {
          t({"Log.d(\""}), i(1, "TAG"), t({"\", \""}), i(2, "message"), t({"\")"}),
        }),
        
        -- ViewModel snippet
        s("viewmodel", {
          t({"class "}), i(1, "MyViewModel"),
          t({" : ViewModel() {", ""}),
          t({"    private val _"}), i(2, "data"), t({" = MutableLiveData<"}), i(3, "String"), t({">()",""}),
          t({"    val "}), i(4, "data"), t({": LiveData<"}), i(5, "String"), t({"> = _"}), i(6, "data"), 
          t({"", ""}),
          t({"    "}), i(0),
          t({"}", ""}),
        }),
      })
      
      ls.add_snippets("xml", {
        -- TextView snippet
        s("textview", {
          t({"<TextView", ""}),
          t({"    android:id=\"@+id/"}), i(1, "textView"), t({"\"", ""}),
          t({"    android:layout_width=\""}), i(2, "wrap_content"), t({"\"", ""}),
          t({"    android:layout_height=\""}), i(3, "wrap_content"), t({"\"", ""}),
          t({"    android:text=\""}), i(4, "Text"), t({"\" />"}),
        }),
        
        -- Button snippet
        s("button", {
          t({"<Button", ""}),
          t({"    android:id=\"@+id/"}), i(1, "button"), t({"\"", ""}),
          t({"    android:layout_width=\""}), i(2, "wrap_content"), t({"\"", ""}),
          t({"    android:layout_height=\""}), i(3, "wrap_content"), t({"\"", ""}),
          t({"    android:text=\""}), i(4, "Click Me"), t({"\" />"}),
        }),
        
        -- LinearLayout snippet
        s("linearlayout", {
          t({"<LinearLayout", ""}),
          t({"    xmlns:android=\"http://schemas.android.com/apk/res/android\"", ""}),
          t({"    android:layout_width=\"match_parent\"", ""}),
          t({"    android:layout_height=\"match_parent\"", ""}),
          t({"    android:orientation=\""}), i(1, "vertical"), t({"\"", ""}),
          t({"    android:padding=\"16dp\">", ""}),
          t({"", ""}),
          t({"    "}), i(0),
          t({"", ""}),
          t({"</LinearLayout>"}),
        }),
      })
    end,
  },
}
