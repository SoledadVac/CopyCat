import SwiftUI

struct BatchQueryResultTable: View {
    let batchResult: BatchQueryResult?
    
    var body: some View {
        if let batchResult = batchResult {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(batchResult.results.indices, id: \.self) { index in
                        let (query, result) = batchResult.results[index]
                        QueryResultCard(
                            index: index + 1,
                            query: query,
                            result: result
                        )
                    }
                }
                .padding()
            }
        } else {
            VStack(spacing: 16) {
                Image(systemName: "tablecells")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text("执行查询以查看结果")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct QueryResultCard: View {
    let index: Int
    let query: String
    let result: Result<QueryResult, Error>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("查询 #\(index)")
                    .font(.headline)
                Spacer()
                switch result {
                case .success:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                case .failure:
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(query)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding()
            
            Divider()
            
            switch result {
            case .success(let queryResult):
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(queryResult.columns, id: \.self) { column in
                            Text(column)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(NSColor.controlBackgroundColor))
                        }
                    }
                    
                    Divider()
                    
                    ScrollView(.horizontal) {
                        LazyVStack(spacing: 0) {
                            ForEach(queryResult.rows, id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(row, id: \.self) { cell in
                                        Text(cell)
                                            .font(.body)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 12)
                                    }
                                }
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    
                    HStack {
                        Text("\(queryResult.rows.count) 行")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "耗时: %.3f 秒", queryResult.executionTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding()
                
            case .failure(let error):
                VStack(alignment: .leading, spacing: 8) {
                    Text("错误:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .font(.body)
                        .foregroundColor(.red)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
            }
        }
        .border(Color(NSColor.separatorColor), width: 1)
        .cornerRadius(4)
    }
}
