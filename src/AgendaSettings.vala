namespace Agenda {
    public class State : Granite.Services.Settings {
        public int width { get; set; }
        public int height { get; set; }
        public State () {
            base ("org.pantheon.Agenda");
        }
    }
}
