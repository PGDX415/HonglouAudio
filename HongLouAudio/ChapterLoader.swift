import Foundation

class ChapterLoader {
    static func loadChapters() -> [Chapter] {
        guard let url = Bundle.main.url(forResource: "chapters", withExtension: "json") else {
            print("JSON file not found")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let chaptersData = try decoder.decode(ChaptersData.self, from: data)
            return chaptersData.chapters
        } catch {
            print("Error loading chapters: \(error)")
            return []
        }
    }
}