# Markinginator ✍️

**AI-Powered Marking & Feedback Enhancement Web App**

> "Behold! The Markinginator™: My **_not-so-evil_** plan to unleash an ingenious, collaborative **grading-inator** that zaps assignments straight from LMS (e.g., Moodle), empowers educators to concoct elaborate marking criteria, harnesses the awesome might of AI for efficient and diabolically consistent feedback, and lets you customise every zap of feedback-ultimately revolutionising the entire Tri-State Area’s teaching and learning experience!" -- _with Heinz Doofenshmirtz's raspy voice_

**WHY I’m doing this? 🙈**

Well, you see, as a kid, I absolutely loved _Phineas and Ferb —_ the wild inventions, Doofenshmirtz’s "-inators," the over-the-top schemes! Now that I’m a Doctor (not the evil kind, I promise), I finally have the power to build my own wacky invention — except this one actually helps people. So why not make grading more fun and helpful for everyone, right? Hahaha! 😈

Anyway, _Markinginator_ is an AI-powered web application that leverages Retrieval-Augmented Generation (RAG) to help teachers collaboratively grade and refine feedback, ensuring textual consistency. Designed to empower educators, _Markinginator_ supports and amplifies your expertise rather than automating everything.

---

## Table of Contents

- [Key Challenges or Context](#key-challenges)
- [Features](#features)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Why Run Locally?](#why-run-locally)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Key Challenges

1. **Manual Grading Overhead:** Grading large numbers of assignments is time-consuming and repetitive, leading to educator fatigue.
2. **Inconsistent Feedback:** Without standardization, feedback quality and tone can vary between markers and assignments.
3. **Integration Complexity:** Moving grades and feedback between Moodle and external tools is often cumbersome and error-prone.
4. **Subjectivity in Grading:** Lack of clear marking criteria and weighting can lead to inconsistent or unfair grading.
5. **Limited Feedback Customization:** Existing tools rarely support blending AI-generated suggestions with educator expertise and commonly used feedback.
6. **Collaboration & Transparency:** Coordinating multiple markers and ensuring transparency in grading distribution and progress can be challenging.
7. **Scalability:** As class sizes and assignment volume grow, maintaining quality and efficiency becomes increasingly difficult.

---

## Features

- **Teacher Feedback Assistant:**  
  Transform rough grading notes into structured, actionable feedback. Customise tone (supportive, direct, neutral) and translate feedback for classrooms.

- **Rubric-centred Grading Support:**  
  Streamline and enhance the grading process with AI-powered suggestions, centralised around rubric while maintaining educators' full control in marking.

- **Collective Common Feedback:**
  Speed up the marking process by automatically identifying recurring strengths and areas for improvement across multiple submissions, allowing educators to generate and apply consistent, batch feedback efficiently.

---

## System Requirements

- **Operating System:** Windows 10+, macOS 10.15+, or Linux (x64)
- **RAM:** Minimum 8GB (16GB recommended for large AI models)
- **Storage:** 5GB+ free space (for local AI model caching)

---

## Installation

1. Clone the repository:

```
git clone https://github.com/yourusername/markinginator.git
cd markinginator
```

2. Set up dependencies:

```
mix setup
```

3. Start the Phoenix server:

```
mix phx.server
```

Or, to run inside IEx:

```
iex -S mix phx.server
```

---

## Usage

Once the server is running, open your browser and visit [http://localhost:4000](http://localhost:4000).

Follow the on-screen instructions to begin marking assignment or generating feedback.

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request. For major changes, please open an issue first to discuss what you would like to change.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Contact

For questions or support, please open an issue on GitHub or contact the maintainer at riordan.alfredo@gmail.com
