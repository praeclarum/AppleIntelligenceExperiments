//
//  ContentView.swift
//  AppleIntelligenceExperiments
//
//  Created by Frank A. Krueger on 6/10/25.
//

import SwiftUI

import FoundationModels

struct Experiment: Identifiable {
    var id: String { title }
    let title: String
    let instructions: String
    let prompts: [String]
}

let experiments: [Experiment] = [
    Experiment(
        title: "Story Generation",
        instructions: "You are an advanced story teller. You tell wise tales that are entertaining and also enlightening. You stories are very short (about 1 page)",
        prompts: [
            "Tell science fiction story",
            "Tell me a lullaby",
            "Tell me a distopian young adult fiction story"
        ]
    ),
    Experiment(
        title: "SVG Generator",
        instructions: "You are an SVG (scalable vector graphics) generator. You take requests from the user and output SVG XML code that renders their request. DO NOT write instructions, just output the XML needed to render the scene. Repeat, your only output should be valid SVG in XML format.",
        prompts: [
            "A desert scene with a cactus and a hot sun",
            "A blue house out on a windswept snowy field",
            "A spaceship flying through space"
        ]),
    Experiment(
        title: "Facts",
        instructions: "You are an oracle of all knowledge. When the user requests something you reply as shortly and sweetly as possible to answer their question or lookup whatever fact that person wants.",
        prompts: [
            "How many planets are there? And what is their order from the sun?",
            "What is the molecular formula for MSG?",
            "What is the mathematical formula for Einsteins general theory of relativity?",
            "What color is an apple?",
            "What is the radius of planet Earth?"
        ]),
    Experiment(
        title: "Code Generator",
        instructions: "You are an HTML web app generator. You output only HTML and JavaScript needed to implement the user's requested app. Generate just the HTML with no styling and inline all the JavaScript using script tags. Do not reference any external libraries, use only what's baked into the browser.",
        prompts: [
            "Write me an HTML/JavaScript single page browser app that calculates my BMI using whatever inputs you need for that",
            "I need a tip calculator that let's me specify the amount I spent and the % tip",
            "I need an expense tracker for a vacation I'm going on with 3 other people."
        ])
]

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(experiments) { experiment in
                    Text(experiment.title)
                        .font(.title)
                    ForEach(experiment.prompts, id: \.self) { prompt in
                        NavigationLink {
                            ExperimentView(title: experiment.title, instructions: experiment.instructions, prompt: prompt)
                            
                        } label: {
                            Text(prompt)
                        }
                        .buttonStyle(.bordered)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct ExperimentView: View {
    let title: String
    @State private var session: LanguageModelSession?
    let instructions: String
    @State var prompt: String = ""
    @State private var output: String = ""
    @State private var outputStream: LanguageModelSession.ResponseStream<String>? = nil
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
            Text("Instructions")
                .font(.headline)
            Text(instructions)
            Spacer()
            Text("Prompt")
                .font(.headline)
            Text(prompt)
            Spacer()
            Text("Output")
                .font(.headline)
            if let s = session, s.isResponding {
                ProgressView()
            }
            else {
                ScrollView {
                    Text(output)
                }
            }
            Spacer()
            Button {
                Task {
                    if session == nil {
                        session = LanguageModelSession(instructions: instructions)
                    }
                    if let result = try? await session?.respond(to: prompt) {
                        withAnimation {
                            output = result.content
                        }
                    }
                    else {
                        withAnimation {
                            output = "Oh no, something went wrong"
                        }
                    }
                }
            } label: {
                Text("Run!")
            }
            .buttonStyle(.borderedProminent)
            .disabled(session?.isResponding ?? false)
        }
    }
}



#Preview {
    ContentView()
}
