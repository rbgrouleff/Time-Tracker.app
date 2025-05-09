Button("Start timer") {
                    }
                    .disabled(navigationContext.selectedProject == nil || navigationContext.selectedTimingSession == nil)
                    .keyboardShortcut(.space, modifiers: [])